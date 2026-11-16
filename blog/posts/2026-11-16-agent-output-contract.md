---
title: Agent 的瓶颈不是模型，是输出契约
date: 2026-11-16
tags: 工程化, 上下文
summary: 换更强的模型对多数 Agent 项目的收益，比把输出契约写死要小；先把结构约束做对，再谈模型升级。
view: 大多数 Agent 项目卡在输出不可解析、不可复现，而不是模型不够聪明。
source: https://github.com/bboyf/world-cup-prediction
draft: false
---

## 先给结论

我的判断很直接：如果你做的 Agent 每隔几天就出现"格式不对、结论飘、同样的输入给出不同答案"，那问题大概率不在模型，而在你没有给模型一个**可校验的输出契约**。换更贵的大模型能掩盖一阵，但掩盖不了两周。

## 现象

我在自己的项目里反复撞到同一种情况：让模型"分析一下这场比赛"，它给的是一段读起来很顺、但无法入库、无法二次比对的话。你需要比分、需要胜率、需要关键因素三个字段，它给你五个自然段。于是你在下游写一堆正则去抠，抠不到就重试，重试三次成本翻倍，结果还不稳定。

这不是提示词不够礼貌的问题，是契约没定义的问题。

## 输出契约到底约束什么

我把这件事拆成四层，缺一层都会漏：

| 层级 | 约束什么 | 失败表现 |
|---|---|---|
| 资料层 | 模型能引用哪些事实 | 开始自己编战绩 |
| 方法层 | 用什么推理流程 | 每次分析角度都不一样 |
| 输出层 | 字段、类型、取值范围 | 结果不可解析、不可入库 |
| 更新层 | 哪些数据每天刷新 | 结论停留在旧数据上 |

绝大多数人只做了第三层的一半，也就是在提示词里写一句"用 JSON 输出"。

## 一个可跑的校验器

真正有用的是**生成后立刻校验，不合格就带着错误信息重试**，而不是盲重试。这段代码可以直接跑：

```python
import json
from datetime import date

SCHEMA = {
    "home_score": (int, 0, 20),
    "away_score": (int, 0, 20),
    "win_prob": (float, 0.0, 1.0),
    "key_factors": (list, 1, 3),
}

def validate(payload: dict) -> list[str]:
    errors = []
    for field, (typ, low, high) in SCHEMA.items():
        if field not in payload:
            errors.append(f"缺少字段 {field}")
            continue
        value = payload[field]
        if not isinstance(value, typ):
            errors.append(f"{field} 类型应为 {typ.__name__}")
            continue
        if typ is list:
            if not (low <= len(value) <= high):
                errors.append(f"{field} 元素个数应在 {low}-{high}")
        elif not (low <= value <= high):
            errors.append(f"{field} 超出范围 {low}-{high}")
    if "as_of" in payload:
        try:
            date.fromisoformat(payload["as_of"])
        except (TypeError, ValueError):
            errors.append("as_of 必须是 YYYY-MM-DD")
    else:
        errors.append("缺少字段 as_of：没有数据日期就无法复现")
    return errors
```

关键在最后那个 `as_of`。**要求模型必须自报数据截止日期**，是让结论可复现的最低成本手段。缺了它，你事后永远分不清"当时判断错了"还是"当时数据就是旧的"。

## 对我的项目意味着什么

世界杯预测引擎就是这么收敛下来的：把资料库锁死、方法论固化、输出契约固定、动态更新单列一层，四层各自有校验点。改完之后最明显的变化不是准确率涨了多少（我没有做过严格的 A/B，这点我不吹），而是**同一个问题跑十次，输出结构完全一致，可以直接进数据库做对比**。

同样的思路对另外两个项目也成立：

- HarmonyOS 记账里的 AI 智能记账，模型输出的分类必须是固定枚举，否则账单统计会串账；
- 人脸识别监控的告警文案，模型只能填写既定字段，不能自由发挥。

## 我的判断可能错在哪

反方最强的论点是：**输出契约只在结构化任务里成立**。如果做的是写作、头脑风暴、开放式研究这类任务，把输出锁成 JSON 恰恰会杀掉模型最有价值的部分，等于用一个更贵的模板引擎。

这点我认。所以我把结论再收窄一次：凡是**结果要入库、要对比、要给别人看**的 Agent 环节，先做契约；纯探索性环节，别做，做了是自残。如果哪天主流模型能稳定做到"任意格式零漂移"，那我这套校验代码就该删掉——但我目前没有看到这个证据。
