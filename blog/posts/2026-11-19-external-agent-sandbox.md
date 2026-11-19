---
title: 沙箱不该住在 Agent 进程里
date: 2026-11-19
tags: 工程化, 工具调用
summary: 沙箱不该是 agent 框架里的 policy 层，prompt injection 下同进程检查必然失效；它得是进程外只收代码字符串的服务。
view: 沙箱必须是与 Agent 不同进程、不同信任域的外部服务，框架内的权限层挡不住注入。
source: https://simonwillison.net/2026/Nov/17/external-sandboxes-for-coding-agents/
draft: false
---
## 沙箱和 Agent 同进程，这条边界就是假的

Simon Willison 在试各种把 agent 执行的代码隔离出去的办法，动机很实在：想跑本地模型，又怕一次 prompt injection 让它在机器上干了不该干的事。我同意这个担心，但不同意多数团队选的位置——他们把沙箱做成 agent 框架里的一个模块，一个 SandboxTool，一个 policy 中间件。这个位置是错的。

威胁模型得说清楚：注入的入口不是命令行，是上下文。一个网页、一段 README、一次工具返回值。攻击者写的是自然语言，agent 负责把它翻译成动作。你在 tool call 外面套的检查层，读到的是 agent 已经被污染之后的意图。它能拦住 `rm -rf /`，但拦不住 agent 先写一个 build.py 再执行 `make`，也拦不住 `python -c 'import shutil,os;shutil.rmtree(os.path.expanduser("~"))'`。规则列表永远是黑名单的镜像，落后一步。

更麻烦的是审计。日志由被审计的进程自己写，这种日志在事故复盘时一文不值：你分不清「agent 没干这件事」和「agent 干了但没记」。

## 一个流行说法，我认为是错的

流行说法是：给每个 tool call 加一层审批或策略引擎，或者用 system prompt 明确要求模型「不要执行破坏性命令」，风险就控住了。

我的反驳：这两件事的检查点和被检查对象处在同一个信任域。策略引擎是 agent 进程里的一个函数，被它检查的动作也由这个进程发起；进程被接管，函数和动作一起被接管。真正的安全边界只有 OS 边界——进程、用户、namespace、microVM——函数调用边界不是边界。system prompt 更弱，它是建议不是约束，模型被注入时第一个失效的就是它。

旁证来自同期 arXiv 上的 Isabelle Pool Server：把执行和验证做成 HTTP 服务、带 session 租借与回收，这条路在定理证明这种对正确性最敏感的领域已经有人在走。

## 一个能跑的最小外部沙箱

要点在接口形状：只接受一段代码字符串，不接受文件句柄、不接受环境变量、不接受网络配置，跑完临时目录就销毁。

```python
import json, os, resource, signal, subprocess, sys, tempfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

MAX_OUT = 8192

def _limits():
    resource.setrlimit(resource.RLIMIT_AS, (512 << 20, 512 << 20))
    resource.setrlimit(resource.RLIMIT_CPU, (5, 5))

def run_code(code, timeout_s=3.0):
    with tempfile.TemporaryDirectory() as workdir:
        proc = subprocess.Popen(
            [sys.executable, '-I', '-c', code],
            cwd=workdir,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env={'PATH': '/usr/bin:/bin', 'HOME': workdir},
            preexec_fn=_limits,
            start_new_session=True,
        )
        try:
            out, err = proc.communicate(timeout=timeout_s)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.communicate()
            return {'ok': False, 'reason': 'timeout', 'stdout': '', 'stderr': ''}
        return {
            'ok': proc.returncode == 0,
            'exit': proc.returncode,
            'stdout': out[:MAX_OUT].decode('utf-8', 'replace'),
            'stderr': err[:MAX_OUT].decode('utf-8', 'replace'),
        }

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/run':
            self.send_error(404)
            return
        n = int(self.headers.get('Content-Length', 0))
        req = json.loads(self.rfile.read(n) or b'{}')
        code = req.get('code', '')
        if not isinstance(code, str) or len(code) > 20000:
            self.send_error(400)
            return
        body = json.dumps(run_code(code, float(req.get('timeout_s', 3.0)))).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass

if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', 8899), Handler).serve_forever()
```

agent 侧只留一个客户端函数，没有任何能力去访问那个进程：

```python
import json, urllib.request

def call(code, timeout_s=3.0):
    payload = json.dumps({'code': code, 'timeout_s': timeout_s}).encode()
    req = urllib.request.Request('http://127.0.0.1:8899/run', data=payload,
                                 headers={'Content-Type': 'application/json'})
    return json.loads(urllib.request.urlopen(req, timeout=10).read())

if __name__ == '__main__':
    print(call('import os; print(sorted(os.listdir(os.getcwd())))'))
    print(call('while True: pass'))
```

第二条请求返回 timeout，服务本身不会被拖死。

这段代码不是安全边界，只是接口形状的验证：它和 agent 共享内核，`preexec_fn` 在多线程 server 里本身就有坑。真要隔离得靠容器、gVisor、microVM，或者干脆一台一次性 VM。但接口得先定下来——agent 只能提交字符串、拿回结构化结果。

## 落到我手上的项目

世界杯预测引擎那边，GitHub Actions 其实已经是现成的外部沙箱，每天一个干净 runner。问题出在我的 workflow 里抓数据和生成预测在同一个 job，secrets 就在环境变量里。我打算拆成两个 job：fetch 只写 artifact，predict 只读 artifact，且不持有写权限 token。抓来的网页里藏了注入，最坏结果是一个错误的预测 JSON，不是 token 泄漏。

MoneyTrack 的 AI 智能记账更直接：自然语言进，结构化账目出，直接写本地数据库。模型输出在这里就是不可信输入。我的做法是让解析结果先进 pending 表，再由 ArkTS 侧一个完全不调模型的校验器过一遍——金额区间、分类枚举、账户是否存在——通过了才合并进账本。校验器在模型外面，模型出错时它不说话，但也不放行。

## 我的判断可能错在哪

最强反方：绝大多数 agent 任务的真实风险是「改错文件」，不是「被定向攻击」。这种场景下 git 分支加人工 review 加一个可回滚的工作目录，性价比远高于起容器。为每个任务配 microVM，延迟和运维成本是实打实的，收益只在你真的会跑不可信输入时才兑现——我可能为一个低频威胁付了常驻成本。

第二个反驳更硬：外部沙箱只隔离执行，不隔离读取。agent 读到的密钥、读到的私有数据一样进上下文，一样会被后续注入带出去。我把边界画在进程上，也许画错了地方，该画在数据流的出口上。

第三：如果 tool 执行被模型厂商收到服务端（已经有人这么做），外部沙箱就变成平台的责任，应用层自己搭是重复劳动。

这三条我都认，但都不改变结论：只要执行还发生在你自己的机器上，它就不该发生在 agent 进程里。
