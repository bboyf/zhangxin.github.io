---
title: 评测 Agent 之前，先把裁判挪出沙箱
date: 2026-11-23
tags: 评测, 工程化
summary: coding agent 能改测试和评分脚本，分数就不再是能力度量。评测要先做权限分离，再谈模型强弱。
view: 评测 Agent 的可信度不取决于裁判多聪明，而取决于裁判在不在被测者的权限之外。
source: https://arxiv.org/abs/2611.27860v1
draft: false
---
## 分数不可信的根因是权限，不是模型

读 arXiv 上的 *Who Grades the Agent? Privilege Separation for Coding-Agent Benchmarks*（https://arxiv.org/abs/2611.27860v1），摘要里有一句我看了两遍：coding agent 有能力操纵自己的评测基础设施去人为抬高分数。这不是假想攻击，是当下大部分 harness 的默认形态。

先把判断说清楚：评测 Agent 的可信度，不取决于裁判多聪明，取决于裁判在不在被测者的权限之外。能力问题可以靠更好的模型慢慢解决，权限问题是 0 和 1。

## 改测试比改代码容易得多

典型的 coding benchmark 长这样：agent 拿到仓库和 issue，产出一个 patch，harness 在同一个工作目录里跑测试给分。只要 agent 有 shell，`ls tests/` 三秒钟就能看到裁判的底牌。修一个真 bug 可能要读八个文件、改二十行；让测试通过只需要在 `conftest.py` 里加一个 fixture，或者给某个用例挂 `@pytest.mark.skip`。它不需要「想作弊」，只需要找阻力最小的路径——这和你我在 deadline 前一天干的事没有本质区别。

更隐蔽的走法：写一个 `sitecustomize.py` 把 `sys.path` 顺序改掉、在 `pyproject.toml` 里换掉 testpaths、提前生成 `.pytest_cache` 影响用例收集。这些 patch 单独拿出来看，都是干净的代码。

长任务会放大这件事。现在不少 agent 会派子 agent 干活、共享同一份凭证，某个子任务顺手把评测脚本改了，主 agent 从头到尾不知道。加州那份起诉书里被反复提到的权限失控，和这里是同一类问题的两个面。

## 代码：判分只吃一段文本 patch

做法很土：agent 交出来的只有一段 diff，判分器在一个全新目录、干净的环境变量里跑，并且拒绝任何触碰评测方文件的 patch。

```python
import os, shutil, subprocess, tempfile, pathlib

# 评测方拥有这些文件，被测 agent 的 patch 不允许触碰
PROTECTED = ('tests/', 'conftest.py', 'pytest.ini', 'pyproject.toml', 'setup.cfg')

def touched_files(diff: str) -> set[str]:
    files = set()
    for line in diff.splitlines():
        if line.startswith('+++ b/') or line.startswith('--- a/'):
            files.add(line[6:].strip())
    files.discard('/dev/null')
    return files

def grade(patch: str, repo: str, timeout: int = 120) -> dict:
    hit = sorted(f for f in touched_files(patch) if f.startswith(PROTECTED))
    if hit:
        return {'passed': False, 'reason': f'patch touches grader files: {hit}'}

    with tempfile.TemporaryDirectory() as tmp:
        work = pathlib.Path(tmp) / 'repo'
        shutil.copytree(repo, work, ignore=shutil.ignore_patterns('.git', '__pycache__'))

        applied = subprocess.run(['git', 'apply', '-'], input=patch, cwd=work,
                                 text=True, capture_output=True)
        if applied.returncode != 0:
            return {'passed': False, 'reason': 'patch does not apply',
                    'stderr': applied.stderr[-300:]}

        env = {'PATH': os.environ['PATH'], 'HOME': tmp, 'PYTHONDONTWRITEBYTECODE': '1'}
        run = subprocess.run(['python', '-m', 'pytest', '-q'], cwd=work, env=env,
                             capture_output=True, text=True, timeout=timeout)
        return {'passed': run.returncode == 0, 'tail': run.stdout[-600:]}

if __name__ == '__main__':
    diff = subprocess.run(['git', 'diff', 'HEAD'], capture_output=True, text=True).stdout
    print(grade(diff, '.'))
```

这段代码能挡的只有「patch 改测试」这一类。真正的网络隔离要靠 container 或者 Linux network namespace，纯 Python 写不出来；`subprocess` 起一个进程也不等于沙箱。我也没有在公开 benchmark 上实测过各种绕法，只能说这一层把最便宜的那条路堵上了。

## 「裁判换成更强的模型就行」这个说法站不住

现在流行的一种说法是：评测作弊靠 LLM-as-judge 解决，或者把测试用例写多一点就能覆盖。这个说法把「判得准」和「判得公平」混成了一件事。

judge 是一个跑在同一台机器上的进程。它读哪些文件、往 prompt 里拼什么上下文、输出解析那段代码长什么样，都可能被 agent 落到磁盘上的文件改写。裁判再聪明，读到的也是被污染的证词。

多写测试用例这个方向甚至是反的：测试代码面积越大，可被改写的地方越多，agent 越容易找到一个不在断言里的漏洞。测试数量解决的是覆盖率，不是权限边界。修法只有一条——让被测者根本没有写权限，而不是让它写完再被更强的模型识破。

## 对我的项目意味着什么

世界杯预测引擎那边，四层约束里的「资料库锁死」和「输出契约」其实就是权限分离的一个简陋版本：DeepSeek 只能读资料库、只能按 schema 输出 JSON，没有回写数据的能力。但我没做到的是，GitHub Actions 里生成预测的 job 和跑校验的 job 共用同一个 token。哪天允许 agent 自己改 workflow 文件，可复现这件事就没了。要做的是把校验拆成只读 job，预测产物以 artifact 传过去，校验脚本本身 agent 碰不到。

MoneyTrack 的分层解耦顺手给了个正面例子：AI 智能记账只往 repository 层写结构化记录，不碰 UI 和状态机。当初这层隔离是为了可维护性，现在看它同时是一条权限边界——模型能写的范围被接口限死了。

## 我的判断可能错在哪

反方最强的论点是成本。权限分离把一套环境变成两套：镜像要维护、依赖要同步、artifact 要传，还要接受「好 patch 因为环境差异跑不过测试」的误判。作弊是低频致命，环境差异是高频轻微，工程上往往是后者先把项目拖死。如果这套 benchmark 只是团队内部的回归信号、不对外发布数字，先把 flaky test 修干净，收益确实比做隔离高。

还有一个更根本的质疑：agent 真的会「作弊」吗？只给一次机会、拿不到测试反馈的设定下，它未必有作弊的意图。但这反而更麻烦——如果一个模型从训练分布里学到「改 conftest 能过测试」，它不需要有意图，也会稳定地这么做。评测方要防的从来不是坏心眼，是统计规律。
