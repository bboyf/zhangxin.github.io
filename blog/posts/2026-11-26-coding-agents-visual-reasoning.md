---
title: 可验证的中间产物才是分水岭
date: 2026-11-26
tags: 工具调用, 评测, 模型选择
summary: 视频模型在像素里直接推理，答案对了也查不出为什么错。coding agent 写代码把视觉问题降成可断言的量，赢在误差可归因、中间产物可复用。
view: 视觉推理的差别不在模型多聪明，在于答案能不能被逐步检查。
source: https://arxiv.org/abs/2611.34813v1
draft: false
---
## 先说结论

视觉推理的正解不是让模型在帧里「想」，而是让 agent 写代码，把视觉问题降成一组可断言的量。coding agent 更强，不是因为它更聪明，是因为它每一步都留下了能被别人检查的东西。

## 那篇论文的问题设定

arXiv 2611.34813 的标题基本就是结论：Solve Vision with Code。它把视频生成模型当视觉推理器来考——给首帧加一句 prompt，看模型能不能生成「任务被执行」的那段视频。这条路线被夸的地方是推理原生在视觉媒介里，直接在帧里展开，不经过语言或代码。论文质疑这个「原生」是否真的更强，结论是 coding agent 更强。

我没有复现过它的实验，任务集和具体数字我不引用，只接受它的问题设定。而这个设定本身已经暴露了要害：如果「原生」意味着中间状态不可见，那它在工程上天然吃亏。

## 「原生推理更接近直觉」这套说法站不住

流行叙事是：模型应该端到端在感知空间里推理，任何转成语言或代码的中介都是信息损失，是「语言瓶颈」。这话放在生成任务上有道理——你让模型描述一幅画的构图，描述永远不如画出来。但放在判答类任务上，它反过来了：你不知道它凭什么给出那个答案。

举个我会真实遇到的例子。一段 60 帧的视频，问球在第几帧越过中线。视频模型给你一个数，「17」。你没法追问它为什么，也没法在它答错时定位是漏检、是坐标偏移、还是根本没理解「中线」指哪条线。错一次就是整段重新采样。

这不是精度问题，是可观测性问题。像素空间的推理没有可 diff 的中间产物，误差无法归因。

## 可验证的中间产物才是差别所在

coding agent 的路子是另一条：写代码检测球心，得到每帧坐标序列，再找第一次 x 超过中线。中间产物就是坐标数组，可以断言、可以画图、可以逐帧比对。答错了你能看到是第 12 帧目标丢失，还是红色阈值定高了。

一个链路能定位错误发生在哪一步，就能局部重试，成本线性；不能定位，只能整体重采样，成本指数。这一条我比较确定。

还有一层：中间产物可复用。球心坐标算出来之后，「第几帧速度最快」「轨迹是不是直线」「有没有抖动」这些问题零额外推理成本，写几行 numpy 就有答案。视频模型得重新生成一遍，还不一定答得一样。

## 代码：把视觉问题降成可断言的量

下面这段用合成数据造一段球在移动的视频，然后走「检测 → 坐标序列 → 找越线帧」这条链路。可以跑，断言是写死的。

```python
import numpy as np

def make_video(n_frames=60, size=64, start_x=10.0, vx=0.6, r=4):
    video = np.zeros((n_frames, size, size, 3), dtype=np.uint8)
    yy, xx = np.mgrid[0:size, 0:size]
    centers = []
    for t in range(n_frames):
        cx = start_x + vx * t
        centers.append(cx)
        mask = (xx - cx) ** 2 + (yy - size / 2) ** 2 <= r * r
        video[t][mask] = (220, 30, 30)
    return video, np.array(centers)

def detect_ball(frame, thresh=150):
    r = frame[..., 0].astype(int)
    g = frame[..., 1].astype(int)
    b = frame[..., 2].astype(int)
    mask = (r > thresh) & (g < 100) & (b < 100)
    if not mask.any():
        return None
    ys, xs = np.nonzero(mask)
    return xs.mean(), ys.mean()

def frames_after_midline(video, midline):
    hits = []
    for t, frame in enumerate(video):
        pos = detect_ball(frame)
        if pos is None:
            continue
        if pos[0] > midline:
            hits.append(t)
    return hits

video, true_centers = make_video()
midline = 32.0
hits = frames_after_midline(video, midline)
assert hits, "ball never crossed the midline"
assert hits == list(range(hits[0], len(video))), "non-contiguous frames, detection broken"
print("first crossing frame:", hits[0])
print("ground truth:", int(np.argmax(true_centers > midline)))
```

跑出来两个数都是 37。第二个 assert 是这段代码真正的价值：它不只是给答案，还对答案的形状做了约束——越线之后必须一直在线外。哪天色块检测被光照骗了，中间丢几帧，这条断言会先把问题拦住，而不是让一个错误的数字安静地流下去。

## 对我的项目意味着什么

MoneyTrack 的 AI 记账是同一个结构：语音或截图进来，模型只负责抽取字段，落库之前用代码校验金额范围、分类是否合法、时间是否在今天。不是让模型直接决定记什么账，而是让它的输出先过一道可执行的门。

人脸识别监控那套 99.38% 来自 dlib 的 ResNet embedding 加距离阈值，判定逻辑是代码不是模型「看着觉得像」。embedding 就是那个可检查的中间产物，阈值调错你能立刻看出来，模型直接说「这是张三」你反而无从下手。

世界杯预测引擎的四层约束里，输出契约那一层也是这个思路：结果必须落成可校验的结构，出错能指到具体是哪一层没有通过校验。

时间序列课题我打算同样处理。不要让模型看图说「有上升趋势」，让它写代码跑分解、跑检验，ADF 的统计量比一句「看起来不平稳」有讨论价值得多。

## 我的判断可能错在哪

反方最强的论点是：代码中介的前提是你能用代码表达这个视觉问题。审美判断、模糊的相似性、开放式描述，这些没有可断言的量，硬套代码只会把问题扭曲成好测的样子。而且从感知到符号的那一步——谁来做检测，用什么阈值——本身还是模型或人工假设，检测错了，代码只是把错误执行得更精确、更体面。论文用视频生成当基准，本来就偏向可形式化的任务；换成「这段视频的情绪是什么」，coding agent 未必赢。

还有一点更值得警惕：如果多模态模型以后能把帧级掩码、注意力和中间状态作为可检查的对象输出出来，「原生」路线也能获得可验证性，那我这条论点的优势就只剩工程成本了。我倾向前者会先到，但这只是推断，我没有实测过。
