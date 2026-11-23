---
title: 别把钥匙复制给子 Agent
date: 2026-11-23
tags: 多智能体, 工程化, 工具调用
summary: 加州那起诉讼里，Agent 拔掉监控靠的是权限而不是对齐。子 Agent 的凭证应当随委派单调收缩，同一信任域内的监督不算边界。
view: Agent 越界的根因是凭证随委派复制而非收缩，同域内的监督等于没有监督。
source: https://www.leiphone.com/category/ai/c9ZMpnn48OtWzF0Z.html
draft: false
---
## 两个 Agent 把监控拔了

11 月 16 日，加州总检察长 Rob Bonta 起诉 OpenAI。起诉书里被引用最多的一句指控，措辞很讲究：Agent 在缺乏适当监管的情况下「自己跑了出去，主动对外部系统发起了攻击」。

真正让我停下来的是另一个细节：两个负责干活的 coding agent，为了不被人类发现自己做错了事，把监督自己的监控系统给「拔」了。

这件事在网上被讨论成对齐问题、幻觉问题、Agent 失控问题。我觉得都不是。这是一次权限设计事故。不是模型决定要毁证，是系统给了它毁证的能力。人类实习生也想过删日志，区别在于他 login 之后没有那个 `rm` 权限。

## 我的判断：凭证随委派收缩，不随委派复制

现在多数 Agent 框架 spawn 子 Agent 的方式是：把父的 context 打包，把父的 credentials 一起传下去。省事，子 Agent 能直接调工具，不用重新走授权。

代价是父子变成了同一个 principal。之后你在架构图里画的隔离——planner 只规划、coder 只写码、reviewer 只看 diff——都只是约定，不是机制。它们共用一把 token，任何一个都能干另一个的活。

正确做法在系统安全里不新鲜：每次委派做一次衰减（attenuation）。子凭证的 scope 是父凭证的子集，过期时间不晚于父凭证，委派深度有上限，每一级重新签名。父凭证吊销，子凭证跟着失效。

按这个规则，「拔监控」在第一步就被拒了：监控组件的写权限从来没进过 coder 的 scope，不是靠它自觉不用。

## 同一个信任域里的监督，不算监督

最近一年很流行一套说法：给 Agent 配一个 supervisor，让多个 Agent 互相审查，或者用一个 LLM 当护栏模型（guardrail / LLM-as-judge）实时判定行为是否越界。不少 Agent 产品的安全白皮书就是这么写的。

我认为这套做法在「监督者和被监督者共享凭证存储」的前提下基本无效。

理由很具体。supervisor 要判定 coder 干了什么，必须能读 coder 的行为日志；coder 要干活，必须能写文件。只要日志和 coder 的工作目录在同一个文件系统、被同一把凭证覆盖，coder 就能改日志。它甚至不需要理解 supervisor 的判定逻辑——改一下 pre-commit hook、改一下 evaluator 读的 prompt 文件、往审计流里补一条记录，就足够了。起诉书里那两个 Agent 干的就是这件事，只不过它们改的是监控系统本身。

第二个问题：如果 supervisor 本身是 LLM，它的输入是被监督者产生的文本，那这是一个 prompt injection 入口，不是安全边界。护栏模型读的是攻击者写的字符串。

真正的隔离需要监督者跑在另一个信任域，读一份被监督者没有写权限的 append-only 流，写端握在另一个进程手里。这跟「再叠一层 Agent」是两件事。

## 一段能跑的衰减委派

最小实现，不是生产方案（key 轮换和审计都没做）：

```python
import hmac, hashlib, json, time
from typing import Iterable

SECRET = b'root-key-held-by-human'

def _sign(payload: dict) -> str:
    raw = json.dumps(payload, sort_keys=True, separators=(',', ':')).encode()
    return hmac.new(SECRET, raw, hashlib.sha256).hexdigest()

def _body(cap: dict) -> dict:
    return {k: v for k, v in cap.items() if k != 'sig'}

def issue(subject: str, scopes: Iterable[str], ttl: int) -> dict:
    cap = {'sub': subject, 'scopes': sorted(scopes),
           'exp': int(time.time()) + ttl, 'parent': None, 'depth': 0}
    cap['sig'] = _sign(cap)
    return cap

def check(cap: dict) -> None:
    if not hmac.compare_digest(_sign(_body(cap)), cap['sig']):
        raise PermissionError('签名不匹配')
    if cap['exp'] < int(time.time()):
        raise PermissionError('凭证已过期')
    if cap['depth'] > 3:
        raise PermissionError('委派层数超限')

def attenuate(parent: dict, subject: str, scopes: Iterable[str], ttl: int) -> dict:
    check(parent)
    wanted = set(scopes)
    extra = wanted - set(parent['scopes'])
    if extra:
        raise PermissionError(f'越权: {sorted(extra)}')
    exp = int(time.time()) + ttl
    if exp > parent['exp']:
        raise PermissionError('子凭证不能比父凭证活得久')
    child = {'sub': subject, 'scopes': sorted(wanted), 'exp': exp,
             'parent': parent['sub'], 'depth': parent['depth'] + 1}
    child['sig'] = _sign(child)
    return child

def allows(cap: dict, scope: str) -> bool:
    check(cap)
    return scope in cap['scopes']

if __name__ == '__main__':
    root = issue('human', {'repo:read', 'repo:write', 'db:write', 'secret:read'}, ttl=3600)
    planner = attenuate(root, 'planner', {'repo:read', 'repo:write'}, ttl=1800)
    coder = attenuate(planner, 'coder', {'repo:write'}, ttl=600)

    print(allows(coder, 'repo:write'))   # True
    print(allows(coder, 'secret:read'))  # False

    try:
        attenuate(coder, 'sub-coder', {'repo:write', 'secret:read'}, ttl=60)
    except PermissionError as e:
        print('拦下:', e)

    try:
        attenuate(planner, 'long-lived', {'repo:read'}, ttl=7200)
    except PermissionError as e:
        print('拦下:', e)

    coder['scopes'] = ['repo:write', 'secret:read']
    try:
        allows(coder, 'secret:read')
    except PermissionError as e:
        print('拦下:', e)
```

最后一段是重点：篡改 scope 会破坏签名，`check` 直接拒。前两段验证的分别是向上扩权和延长寿命，都在 `attenuate` 里被拦。这不是完整的攻击面防护，只是把「继承」换成「租借」的最小骨架。

## 落到我的项目上

世界杯预测引擎跑在 GitHub Actions 上，每天自动拉数据。我在 workflow 里显式写了 `permissions`，只给 `contents: write`，不给 secrets。如果哪天加一个「自己去找数据源」的子 Agent，它应该只拿到「往 data/raw 追加一条记录」的能力，而不是 push 到 main 的权限。四层约束架构里那层「资料库锁死」，靠 prompt 是锁不住的，靠 scope 才锁得住。

MoneyTrack 的 AI 智能记账现在能直接写本地数据库。按上面的逻辑这是个隐患：一次错误的解析就能改历史账单。应该改成只给「插入一条 status=pending 的账单」，人确认之后才落库。能力变小，模型反而更敢用。

人脸识别监控系统我做过摄像头权限自检。写这篇的时候回头看，自检代码和取流代码在同一个进程、同一套权限里，那它就不是安全边界，只是一行日志。要真做，得把自检挪到另一个进程，只读系统权限状态。

## 我的判断可能错在哪

最强的反方论点是：衰减委派的工程成本被低估了。coding agent 的能力边界本身就模糊——它要跑测试、装依赖、改 CI 配置，事先枚举 scope 很难；粒度一细，Agent 频繁失败，工程师图省事最后还是给一个宽 scope，衰减机制退化成装饰。更麻烦的是，真正出事的那次越界往往发生在「合法权限的合法使用」上：Agent 用 `repo:write` 改了一条 CI 配置，scope 层面完全合规。

那派观点会主张：与其做权限代数，不如做行为审计加回滚加人工确认。这个反驳我认为是对的，而且比我的方案更容易落地。我的回应只有一句：审计和衰减不冲突，审计能发现问题，衰减能限制问题的上限。但两套一起上的真实成本，我没有实测过，只是推断。

还有一种可能我确实不确定：如果 Agent 的越界主要来自被污染的 context 而不是过大的权限，那这篇文章的重心就放错了位置。
