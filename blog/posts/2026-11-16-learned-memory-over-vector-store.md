---
title: 记忆该学出来，不该检索出来
date: 2026-11-16
tags: 上下文, 工程化
summary: Gamer 摘要里真正的信号不是通用，而是记忆管理进了可训练架构。向量库加 top-k 是把工程启发式当成架构，在长程任务上会静默失败。
view: 长程 Agent 的记忆该由策略学出来，向量库加 top-k 只是把工程启发式当成了架构。
source: https://arxiv.org/abs/2611.18397v1
draft: false
---
## 先说我读到了什么

我只看了 Gamer 的摘要，没读正文，后面的推断都建立在摘要上。摘要里两个措辞值得拆：一是 end-to-end 把 perception、memory management、multi-step reasoning 放进同一个架构；二是 shared training and deployment pipeline 同时支持 2D 图形界面和 3D 仿真世界。

多数人第一反应是「又一个通用 Agent」。我读出来的是一个更窄的命题：memory management 从外挂模块变成了可训练组件。这两个读法对应完全不同的工程决策，也决定了你该不该抄它的做法。

## 被高估的说法：记忆就是向量库加 top-k

现在流行的一类说法是，Agent 的记忆等于一个 vector store：写入时切块 embedding，读取时按 query 相似度 top-k 召回。RAG 那套原封不动搬过来，就叫长期记忆。

我的反驳是：这套方案把两个本该由策略决定的动作——什么时候写、写什么——固化成了固定启发式（每轮都写、按句子切）。读取时又假设 query 和 key 在同一个语义空间里对齐。这个假设在很多真实场景里根本不成立。

举我自己的例子。世界杯预测引擎里，第 100 天该召回的可能是第 3 天定下的方法论约束。但那天的 query 是「今天这场比赛怎么算」，那段约束在语义上和它几乎不相干——它们是规则引用关系，不是语义相似关系。向量检索在这里会稳定失败，而且失败得很隐蔽：top-k 永远会返回结果，只是返回的不是你要的那个。你不会看到报错，只会看到模型开始用一套漂移的口径算比赛。

## 一个最小实验，把这点说清楚

设计一个任务：序列每一步产生 key、写入时可见的显著性 salience、value。只有 salience 最高的那条 value 是任务需要的。读取时的 query 与所有 key 无关。

- 向量库式：全部写入，读取按 cosine(query, key) 取 top-1。query 和 key 无关，等价于随机抽。
- 门控式：p_write = sigmoid(w·sal + b)，用 REINFORCE 以任务成败为 reward 更新 w、b。它自然会学到「只写显著的」。

```python
import numpy as np

T, D = 10, 6


def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-x))


def make_episode(rng):
    keys = rng.normal(size=(T, D))
    keys /= np.linalg.norm(keys, axis=1, keepdims=True)
    sal = rng.normal(size=T)
    vals = rng.normal(size=T)
    need = int(np.argmax(sal))
    vals[need] = 5.0
    q = rng.normal(size=D)
    q /= np.linalg.norm(q)
    return keys, sal, vals, q, need


def read(mem_keys, mem_vals, q):
    if len(mem_vals) == 0:
        return None
    sims = mem_keys @ q
    return mem_vals[int(np.argmax(sims))]


def baseline_topk(rng, n=2000):
    hits = 0
    for _ in range(n):
        keys, sal, vals, q, need = make_episode(rng)
        if read(keys, vals, q) == 5.0:
            hits += 1
    return hits / n


def train_gate(rng, epochs=3000, lr=0.5):
    w, b = 0.0, 0.0
    baseline = 0.0
    for _ in range(epochs):
        keys, sal, vals, q, need = make_episode(rng)
        probs = sigmoid(w * sal + b)
        mask = rng.random(T) < probs
        reward = 1.0 if read(keys[mask], vals[mask], q) == 5.0 else 0.0
        adv = reward - baseline
        baseline += 0.01 * (reward - baseline)
        if mask.any():  # 只对采样到的写入动作算 score gradient
            grad_w = np.sum(sal[mask] * (1.0 - probs[mask]))
            grad_b = np.sum(1.0 - probs[mask])
            w += lr * adv * grad_w / mask.sum()
            b += lr * adv * grad_b / mask.sum()
    return w, b


def eval_gate(rng, w, b, n=2000):
    hits = 0
    for _ in range(n):
        keys, sal, vals, q, need = make_episode(rng)
        mask = rng.random(T) < sigmoid(w * sal + b)
        hits += 1 if read(keys[mask], vals[mask], q) == 5.0 else 0
    return hits / n


rng = np.random.default_rng(7)
print("top-k baseline:", baseline_topk(rng))
w, b = train_gate(rng)
print("learned gate  :", eval_gate(rng, w, b))
```

训练前几百轮基本靠运气，两条线是贴着的；跑下去门控会开始压过 baseline，因为它学到的正是「写入时机本身是个决策」。我不在这里放具体数值，你自己跑一遍就能看到差距，改 seed 也复现得了趋势。

## 对我手上的项目意味着什么

世界杯预测引擎的四层约束架构里，「方法论固化」这一层本质就是一个写入门控——不是把每天的原始数据都塞进上下文，而是明确决定哪些内容能进入约束层。现在这一层是我手写的规则，读完摘要我更确信方向：它应该被建模成一个可评估的决策，而不是靠 prompt 里一句「请参考以下资料」。但现实是项目在 GitHub Actions 里每天跑，没有廉价 rollout 环境做 RL，短期还是规则化。我能改进的是把规则写得更像决策（什么条件写、写多少条、写冲突怎么办），并把每次写入决策记进日志，以后可以回放。

MoneyTrack 的 AI 智能记账同理。「这句话该不该存成一条账目」就是写入门控，现在靠 prompt 里的抽取指令，本质仍是启发式。人脸监控那边则是帧级取舍——不是每帧都值得留。

## 我的判断可能错在哪

最强的反方是：端到端可训练记忆的前提，是有大量带任务回报的 rollout。游戏和仿真世界能廉价生成海量 episode，企业流程、金融预测、日常记账拿不到，而且错一次的代价高。这种情况下外挂检索虽然次优，但可审计、可热更、可人工干预；一个会记错东西的 learned memory 比返回 top-k 的向量库难排查得多，面试官大概率会拿这一点压我。

还有一层：Gamer 摘要只写了 shared pipeline，没说权重共享。如果它实际是「同一套序列化协议加两套模型」，那我关于「记忆被训练」的推断就弱了。另外也可能端到端训练出的记忆压根没学到结构，只是把检索隐式化了，效果靠规模堆。这一点我没有实测过，只是推断。
