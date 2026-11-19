---
title: harness 进化，别让 benchmark 当裁判
date: 2026-11-19
tags: 工程化, 评测, 多智能体
summary: harness 的进化目标不是 benchmark 分数，而是显式与隐式需求：分数只能排序，硬需求必须当门槛，否则只会产出窄补丁。
view: 拿 benchmark 分数当 harness 进化的裁判，必然过拟合；分数只配排序，不配拍板。
source: https://arxiv.org/abs/2611.24924v1
draft: false
---
## 分数是需求的有损压缩

arXiv 上这篇 Agentic Harness Engineering Beta 的摘要里有一句我认同的判断：用一个 evolution agent 去改 harness、再用 benchmark 分数挑改动，产出的往往是 narrow patches，而且会 benchmark-specific（[原文](https://arxiv.org/abs/2611.24924v1)）。我不觉得这是工程事故，这是目标函数决定的必然结果。

harness 是模型外面那一圈东西：工具怎么注册、失败怎么重试、上下文怎么裁剪、错误信息长什么样、什么时候打断用户。这些部件的价值，大部分不落在任何 benchmark 的分数上。你把工具返回的错误码从一段自然语言改成枚举，分数可能纹丝不动，但下游所有分支判断都少一层字符串匹配。反过来，你把重试次数调大，某个用例的通过率涨了，真实场景里用户多等了八秒。

分数是需求的有损压缩。压缩就会丢东西，丢掉的恰好是隐式需求：交互的节奏、失败时的体面、日志能不能让人一眼看懂。摘要里说现有方法 overlook implicit requirements and interaction needs，这是全文最硬的一句。

## 上线与否先过硬门槛，再谈分数

我现在的做法是把 harness 的回归用例分成两类：bench case 算分，contract case 只管过不过。任何一条 contract 挂了，这个版本直接作废，bench 满分也不看。

```python
from dataclasses import dataclass, field

@dataclass
class Case:
    name: str
    kind: str          # "bench" 或 "contract"
    passed: bool
    weight: int = 1

@dataclass
class Candidate:
    tag: str
    diff_lines: int
    cases: list = field(default_factory=list)

def contract_failures(cases):
    return [c.name for c in cases if c.kind == "contract" and not c.passed]

def bench_score(cases):
    bench = [c for c in cases if c.kind == "bench"]
    total = sum(c.weight for c in bench)
    if total == 0:
        return 0.0
    got = sum(c.weight for c in bench if c.passed)
    return round(got / total, 4)

def select(candidates):
    alive = [c for c in candidates if not contract_failures(c.cases)]
    if not alive:
        return None, "所有候选都踩了硬需求"
    best = max(alive, key=lambda c: (bench_score(c.cases), -c.diff_lines))
    return best, "ok"

cands = [
    Candidate("retry-x5", 12, [
        Case("tool_call_accuracy", "bench", True, 3),
        Case("multi_step_task", "bench", True, 2),
        Case("error_msg_readable", "contract", False),
    ]),
    Candidate("schema-strict", 40, [
        Case("tool_call_accuracy", "bench", True, 3),
        Case("multi_step_task", "bench", False, 2),
        Case("error_msg_readable", "contract", True),
        Case("degrade_path_exists", "contract", True),
    ]),
    Candidate("schema-strict-plus", 260, [
        Case("tool_call_accuracy", "bench", True, 3),
        Case("multi_step_task", "bench", False, 2),
        Case("error_msg_readable", "contract", True),
        Case("degrade_path_exists", "contract", True),
    ]),
]

best, why = select(cands)
for c in cands:
    print(c.tag, bench_score(c.cases), contract_failures(c.cases))
print("选中:", best.tag if best else None, "|", why)
```

跑出来的结果是：`retry-x5` 的 bench 分数 1.0，但 `error_msg_readable` 挂了——它把错误信息退化成了裸 traceback，用户第一屏看到的是栈。`schema-strict` 掉了一条 bench，分数 0.6，补丁只有 40 行，人能读完。`schema-strict-plus` 分数一样，补丁 260 行。最后选 `schema-strict`。这段代码里的数字是我编来演示规则的，不是实测数据。

论文对「单个 agent 同时改多处」的批评我也认：一个 agent 在同一轮里既动重试策略又动上下文裁剪，出问题时你没法归因。把「提改动」和「判改动」拆成上下文隔离的两个角色会不会更好，我没有实测过，这只是我的推断。

## 「给个分数，agent 就能自己把 harness 刷好」这套说法的问题

这套说法在 demo 里成立，在长期项目里不成立。

第一，搜索空间是被分数定义的。分数不涨的方向，agent 不会去试，哪怕那才是真瓶颈。第二，benchmark 分数和真实体验不单调，摘要说的 narrow patches 就是这个：每次只改能让分动一点的地方，改到后面 harness 变成一堆针对用例的特判。第三，单 agent 自评自改没有对抗，它真心相信自己的补丁是好的。顺带说一句，[external sandboxes for coding agents](https://blog.primeradiant.com/external-sandboxes-for-coding-agents/) 那类工作解决的是执行边界，和这里说的裁判边界是两件事，别混着谈。

我的反驳落点很直接：harness 的进化交给一份人写的需求清单加一套不可谈判的 contract case，agent 可以提改动，裁判不能是分数。

## 对我的项目意味着什么

世界杯预测引擎的四层约束里，最像 contract case 的是输出契约那层：比分、概率、理由必须按固定结构返回。拿「预测准不准」当唯一裁判去调这一层，最省事的做法就是把理由字段砍掉——反正它不影响命中率。可理由字段是复盘用的，砍了之后我再也说不清某天的预测为什么错。

MoneyTrack 那边同理。AI 智能记账有一条隐式需求：识别失败必须回退到手动填单，而不是弹一个置信度数字就结束。这条需求在任何准确率 benchmark 里都是零分项，但它是产品能不能用的分界线。

## 我的判断可能错在哪

反方最强的一击是：需求清单本身也会腐烂。人写的 contract case 覆盖不了自己没想到的场景，benchmark 至少是外部给的、不会自我安慰。当瓶颈正好落在你没想到的地方时，刷分反而是一种探索。这个反例我认，所以我的做法是 contract case 只放「确定不能破的底线」，其余交给分数，而不是把需求写成一本谁也读不完的册子。
