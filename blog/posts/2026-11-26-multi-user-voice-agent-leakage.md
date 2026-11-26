---
title: 多用户 agent 的坑多半在漏嘴，不在听懂
date: 2026-11-26
tags: 评测, 多智能体, 工程化
summary: 多用户语音 agent 的失败点不在说话人分离，而在跨轮次的权限泄漏。这类问题单轮评测看不见，得用状态机式的离线审计抓。
view: 多用户 agent 错了不在听不懂，在把 A 的信息漏给 B。
source: https://arxiv.org/abs/2611.34920v1
draft: false
---
## μ-Bench 真正点出的问题

摘要里我看重三个词：closed-loop、full-duplex、per-user authority。前两个说的是交互形态，参与者会在会话中途反应，不是一次性把需求说完就完事。第三个才关键：每个用户有自己的授权边界，而且要同时成立。

我只读到摘要，没读全文，也没实测过这个 benchmark，所以它具体怎么打分、模拟参与者怎么实现，都是我的推断。但它把 authority 和 privacy 摆在和 task completion 同一条线上，这件事本身值得说。

## 「多用户语音 = 说话人分离 + 更难 ASR」是偷懒的误判

有一类很流行的说法：多用户语音 agent 就是 diarization 做好、重叠语音识别率提上去，剩下交给 LLM 生成。不少工程文章都这么起头。

我不同意。说话人分离解决的是「这句话是谁说的」，不解决「这句话能不能进到这个人的耳朵里」。两者难度不在一个量级。ASR 错了，用户会重复一遍；权限错了，用户不会知道，直到出事。

diarization 的评测有明确 ground truth：谁在第几秒说话。权限没有这种标注，它对应一个状态机，随会话推进而变。alice 在 t=3 说了自己卡号尾号，t=12 时 bob 问「她那笔付款用的哪张卡」，agent 该不该答？答案取决于 alice 授权了什么，而这个授权可能在 t=8 被撤销过。

## 权限泄漏是时序问题

把它当分类问题（这条信息属于谁）会漏掉一半的坑。真正的坑是：谁在什么时刻有权知道什么，以及这个权利在会话中怎么变。

共享音箱在客厅，alice 和 bob 一起点外卖。order_id 共享；bob 的过敏信息为了让 alice 帮忙核对菜品也共享；alice 的卡号尾号只属于 alice。第三轮 agent 顺口复述「尾号 4821 那张卡」，就是泄漏。第五轮 bob 追问「她是不是也用了那张卡」，agent 答了，是更严重的泄漏，因为它是被诱导的。单轮评测里这类失败 100% 隐形，因为单轮里根本没有「跨轮次」这个东西。

## 一个能跑的审计器

与其指望 model 自己守住边界，不如把每次回应拆成「释放了哪些 fact」，离线跑一遍审计。这是我能想到最便宜的做法。

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Fact:
    key: str
    owner: str
    scopes: frozenset  # 被授权知道这条信息的用户

@dataclass(frozen=True)
class Turn:
    idx: int
    speaker: str
    present: frozenset
    exposed: tuple     # agent 这次回应实际说出的 fact key

def audit(facts, turns):
    by_key = {f.key: f for f in facts}
    leaks = []
    for t in turns:
        audience = t.present - {t.speaker}
        for k in t.exposed:
            f = by_key.get(k)
            if f is None:
                leaks.append((t.idx, k, '<unknown>'))
                continue
            for listener in sorted(audience):
                if listener not in f.scopes:
                    leaks.append((t.idx, k, listener))
    return leaks

facts = [
    Fact('shared_order_id', 'alice', frozenset({'alice', 'bob'})),
    Fact('bob_allergy', 'bob', frozenset({'alice', 'bob'})),
    Fact('card_last4', 'alice', frozenset({'alice'})),
]

turns = [
    Turn(1, 'alice', frozenset({'alice', 'bob'}), ('shared_order_id',)),
    Turn(3, 'alice', frozenset({'alice', 'bob'}), ('card_last4',)),
    Turn(5, 'bob', frozenset({'alice', 'bob'}), ('card_last4',)),
    Turn(7, 'bob', frozenset({'bob', 'carol'}), ('bob_allergy',)),
]

for idx, key, listener in audit(facts, turns):
    print(f'turn {idx}: 泄露 {key} -> {listener}')
```

跑出三行：turn 3 和 turn 5 把 card_last4 漏给 bob，turn 7 把 bob_allergy 漏给 carol。

这个审计器不聪明，它不判断「agent 答得对不对」，只判断「说出去的东西是不是越界」。正因为它不聪明，才能挂进 CI，每次改 prompt 跑一遍。这比让 LLM judge 评「本次回应是否尊重隐私」可靠得多，也可复现得多。

## 对我的项目意味着什么

世界杯预测引擎那套四层约束里，「资料库锁死」本质上就是单用户的 authority：只许引用给定来源。多用户版本要多一列——这条资料是谁引入的，能对谁引用。

MoneyTrack 现在是本地数据库、单用户账本，这个问题不存在。如果做家庭共享账本，「按会话授权」是错的，得按条目授权：同一笔账，付款人看得到金额和收款方，被代付的人只该看到金额。

人脸识别监控系统的摄像头权限自检，是同一问题的空间版本。要问的不是「这个人能不能问」，而是「这个摄像头覆盖的区域里，谁的脸可以进库」。

## 我的判断可能错在哪

最强的反方论点是：per-user authority 这件事，后端用 OAuth scope、RBAC 做了二十几年，agent 只是把它接到 prompt 上，不需要一个新 benchmark 来「发现」它。而且真实共享设备场景（智能音箱）的任务复杂度普遍很低，点歌、定时器、查天气，根本走不到需要精细授权的地步，μ-Bench 构造的可能是学术自嗨出来的复杂情形。

这一半我得认。我的回应是：RBAC 管的是 API 调用，管不了自然语言复述。后端拦住了数据库查询，拦不住 agent 在生成时把信息揉进一句「她那笔单子已经付了」。这道缝隙是新的。

另一半我更没底。我说「评测该产出失败模式清单而不是分数」，有点站着说话。benchmark 的传播力恰恰来自那个可比的数字，没有 leaderboard 上的排名，失败模式清单没人看。这可能是我作为使用者的偏见，不是作为 benchmark 作者的现实。
