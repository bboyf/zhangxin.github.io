---
title: 长程 Agent 缺的不是上下文，是遗忘
date: 2026-11-16
tags: 上下文, 工程化, 推理成本
summary: 长程 agent 的瓶颈是遗忘策略而非上下文长度。Gamer 把记忆管理放进训练管线，方向对，但端到端学记忆的证据还很薄。
view: 长程 agent 的稀缺资源不是上下文长度，是可学习的遗忘策略。
source: https://arxiv.org/abs/2611.18397v1
draft: false
---
## Gamer 让我在意的不是它能玩游戏

arXiv 上这篇 Gamer（2026-11-13）的摘要写得很省：端到端架构，把感知、记忆管理、多步推理放进同一条训练和部署管线，一套东西同时吃 2D 图形界面和 3D 模拟世界，做法是先做继续预训练。摘要没交代 memory 模块的具体形态，我也没读到正文，所以下面涉及它内部机制的部分都是推断，不当事实用。

我在意的是它把 memory management 放在架构描述的第一句。这不是随口一提的位置——大多数 agent 工作会把记忆塞进「我们还用了向量库」这种工程细节里。

我的判断：长程 agent 的稀缺资源不是上下文长度，是遗忘。一个不会主动丢东西的 agent，任务一长就会自己把自己压死。

## 「上下文够长就能做长程任务」这个说法我不同意

这两年的流行说法是：窗口涨到几十万、上百万 token，长程任务自然解决，实在不够就在外面挂个向量库做检索。

我认为这个说法混淆了「存得下」和「用得上」。三个具体理由。

第一，成本曲线不对。长程任务的步数是几十到几百，每一步都把历史全量喂进去，token 消耗随步数近似平方增长。世界杯预测引擎那个项目我每天跑 GitHub Actions，如果每轮都把全部历史新闻重新喂一遍，账单和延迟会先炸，而不是模型先变聪明。

第二，不可复现，这是我最在意的一点。上下文里塞了什么，取决于检索命中了什么，命中又取决于 query 的措辞。同一场比赛、同一批数据，改一句提示词，检索结果变了，预测就变了，而我无法解释是哪一步的输入导致的。四层约束架构存在的意义就是把这件钉死：资料库锁死、方法论固化、输出契约固定，剩下的才允许浮动。

第三，长上下文里的信息密度是被稀释的。注意力衰减的具体幅度我没有实测过，只是从自己做长文档抽取的经验推的：塞进去的东西越多，模型越容易抓住最近的那几条，早期写入的关键约束反而被淹没。

所以「记忆」这个词的重点不在「记」，在淘汰规则。

## 手写淘汰规则会在哪儿翻车

端到端训练 memory management 的价值，我理解是把「忘掉什么」和「后续动作的收益」绑在一起学，而不是让人去写 if-else。手写规则的问题是边界写不完，下面这个是我在一个长程任务里用过的最小版本，纯标准库，可以直接跑：

```python
from dataclasses import dataclass

@dataclass
class Slot:
    key: str
    value: str
    salience: float   # 0~1，由模型或规则给出
    written_at: int
    hits: int = 0

class ForgetfulMemory:
    '''容量固定的记忆表：写入即可能淘汰，读取刷新命中数。'''
    def __init__(self, capacity: int, decay: float = 0.9):
        self.capacity = capacity
        self.decay = decay
        self.slots: dict[str, Slot] = {}

    def write(self, step: int, key: str, value: str, salience: float) -> None:
        if key in self.slots:
            s = self.slots[key]
            s.value = value
            s.salience = max(s.salience, salience)
            s.written_at = step
            return
        if len(self.slots) >= self.capacity:
            self._evict(step)
        self.slots[key] = Slot(key, value, salience, step)

    def read(self, key: str):
        s = self.slots.get(key)
        if s is None:
            return None
        s.hits += 1
        return s.value

    def _score(self, step: int, s: Slot) -> float:
        age = step - s.written_at
        return s.salience * (self.decay ** age) + 0.1 * s.hits

    def _evict(self, step: int) -> None:
        victim = min(self.slots.values(), key=lambda s: self._score(step, s))
        del self.slots[victim.key]

mem = ForgetfulMemory(capacity=4)
mem.write(1, 'goal', 'unlock the north gate', 0.9)
mem.write(2, 'key', 'found brass key in drawer', 0.6)
mem.write(3, 'npc', 'guard walks east every 6 steps', 0.7)
mem.write(4, 'map', 'corridor B is a dead end', 0.4)
mem.write(5, 'inventory', '2 potions', 0.5)
mem.read('key')
mem.write(6, 'goal', 'north gate is locked; need lever', 0.95)
mem.write(7, 'lever', 'lever is behind the waterfall', 0.8)
print(len(mem.slots), sorted(mem.slots))
```

跑出来是 `4 ['goal', 'key', 'lever', 'npc']`。看淘汰顺序：先扔掉「corridor B is a dead end」（显著度低且老），再扔掉「2 potions」。前一个是合理的，后一个是错的——背包状态的显著度天然低，但它属于永远不该被忘的那一类。纯 salience 打分区分不了「不重要」和「重要但平淡」。

这就是我认为端到端学记忆真正要解决的问题。人写规则时只能按类型硬编码保底项，规则一多就互相打架；如果 salience 由模型根据「当前子目标还差什么」给出，那「2 potions」在需要回血的时刻会自动抬高。代价是你要有足够长的轨迹数据来监督这个打分，而这类数据恰恰最难造——游戏可以录制，真实业务不行。

## 落到我手上的几个项目

世界杯预测引擎的四层约束，本质是记忆分区，不是提示词技巧。资料库锁死是不可遗忘层：赛制、球队名单、历史交锋，谁都不能覆盖。动态更新是可衰减层：伤停、近期状态、赔率漂移，按日期加权。如果把这两层混在一张表里按显著度排序，一条爆炸性新闻就能把赛制规则挤出去，然后模型开始编造小组出线条件。这条我吃过亏，所以现在锁死层是只读文件，代码层面禁止写入。

MoneyTrack 是另一回事。本地数据库是长期记忆，四层解耦真正的价值在于定义「哪一层的写入可以丢」。AI 智能记账解析一句话时，抽取结果出错是常态，正确做法是降级到原始流水、保留原文，而不是用解析结果覆盖账目。这里该被遗忘的是中间表示，不是事实。

人脸识别监控系统里，dlib 的 128 维 embedding 就是记忆本身。实时视频流里真正需要设计的不是把 gallery 越扩越大，而是「什么时候承认这个人已经离开画面」——一个遗忘窗口。99.38% 是离线数据集上的指标，在线退化多少我没有实测过，但我能确定它和 gallery 的淘汰策略强相关。

## 我的判断可能错在哪

最强的反方论点是这样：Gamer 摘要里真正的卖点是「同一套管线跑 2D GUI 和 3D 世界」，贡献在感知与动作空间的统一，记忆只是顺带。如果它的实验主要证明的是泛化性而不是长程稳定性，我把 memory 拎出来当主角就是误读。而且我拿一篇没读正文的摘要去撑一个架构级判断，证据链本身很薄。

第二个反方：外部记忆加规则淘汰比端到端可学记忆更可审计。做过线上系统的面试官大概更信任「显式策略 + 日志」，而不是「模型自己学会了忘」。这个反驳我认为在 To B 场景基本成立，我上面举的背包例子也承认了手写规则只是不够好，不是不能用。

第三个：如果 KV cache 优化和稀疏注意力把长上下文的成本继续压下去，「长上下文够用」的经济学理由会被削掉一大半，遗忘就只剩可复现性这一个支撑点。那也够了，但比我标题里写的要弱。
