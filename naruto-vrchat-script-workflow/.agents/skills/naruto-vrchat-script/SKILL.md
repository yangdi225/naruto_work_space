---
name: naruto-vrchat-script
description: 分析火影搞笑配音对标，并通过故事先行的荒唐事件、行动升级和故事红队，生成适合 VRChat 正反打的火影沙雕短视频脚本。用于对标拆解、自动选题、脚本生产、改写和发布复盘；不用于严肃剧情解说、伤感同人或设定科普。
---

# Naruto VRChat Script

让火影角色在原著关系和能力逻辑中现场冲突。笑点必须依赖火影身份、忍术、旧账或忍界规则，不能只把现实段子换角色名。输出应能用 VRChat Avatar、站位、动作、停顿和正反打完成。

## 默认生产模式

用户要求生成选题或脚本时，默认读取：

- `references/autopilot-workflow.md`
- `../../../knowledge/taste-profile.md`
- `../../../prompts/00-autopilot-pipeline.md`

默认使用 V4 故事先行模式：内部完成 5 个事件前提、2 个升级阶梯和 1 个完整事件版，只向用户交付冠军。不要保存长篇候选赛记录，不要求用户逐轮调试。用户明确要求“短版”时才从完整事件剪成 20-40 秒；用户明确要求“深度筛选”或批量策划时才展示候选。

## 任务路由

### 对标分析
读取：

- `references/account-positioning.md`
- `references/benchmark-analysis-rules.md`
- `references/benchmark-style-writing-rules.md`
- `templates/benchmark-analysis-template.md`

测量钩子、对话轮数、句长、第一次打脸、主动权转移和结尾机制。迁移节奏关系，不复制固定句式。

### 公式提取
读取：

- `references/formula-components.md`
- `references/formula-library.md`

新脚本默认选择 `1 个冲突引擎 Cxx + 1 个火影载体 Nxx + 1 个收尾机制 Pxx`。旧 F 编号只记录来源；F008 当前处于冷却。

### 选题生成
读取：

- `references/autopilot-workflow.md`
- `references/story-first-production-rules.md`
- `references/candidate-selection-rules.md`
- `references/comedy-intensity-rules.md`
- `references/comedy-red-team.md`
- `references/topic-quality-rules.md`
- `references/production-inventory-rules.md`
- `references/character-profiles.md`
- `../../../knowledge/topic-pool.csv`
- `../../../knowledge/script-evaluations.csv`
- `../../../knowledge/production-inventory.csv`
- `../../../knowledge/taste-profile.md`

默认内部生成 5 个荒唐事件前提，至少淘汰 3 个；两强各写“错误执行 -> 升级一 -> 升级二 -> 可见结算”阶梯，故事红队后只扩写冠军。用户指定具体选题时，内部比较两个行动阶梯后只扩写一版，不把选择成本交给用户。

单条反馈“无聊”或“奇怪”时记录失败机制，下一次生产禁用同类，不在当前请求内继续生成长稿。最近连续 3 条均为“无聊”或“奇怪”，或用户明确要求校准时，才切换为 6 条冷开场人工校准模式。

### 正式脚本
读取：

- `references/character-behavior-credibility.md`
- `references/character-voice-bank.md`
- `references/benchmark-style-writing-rules.md`
- `references/expansion-regression-rules.md`
- `references/story-first-production-rules.md`
- `templates/script-output-template.md`

只扩写事件阶梯冠军并执行一次故事损耗检查，再制作 VRChat 分镜。默认先写 60-90 秒完整事件版；短版只能从完整事件剪出。默认 2-4 个角色、1-2 个场景，台词差异来自角色的思考方式和反应速度。

### 质检和改写
读取：

- `references/quality-checklist.md`
- `references/comedy-red-team.md`
- `references/story-first-production-rules.md`
- `templates/quality-check-template.md`

保存脚本后运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-script.ps1 -Path <脚本文件> -Strict
```

硬错误不为 0 时不能判定通过。创意质检先看匿名事件链和裸台词，不读取原稿自评分和胜出理由，不使用百分制或固定峰值位置证明好笑。每次请求最多内部重写一次，改写后重新运行校验器。

### 反馈闭环
读取 `references/feedback-loop.md`，并更新：

- `../../../knowledge/topic-pool.csv`
- `../../../knowledge/script-evaluations.csv`
- `../../../knowledge/historical-scripts.md`
- `../../../knowledge/script-retrospectives.md`

用户评价和真实发布数据优先于生成器自评分。没有数据时留空，不编造表现。

面向用户默认只收集 `保留 / 一般 / 无聊 / 奇怪` 一个标签；具体台词反馈为可选。每累计 5 条人工评价更新一次 `../../../knowledge/taste-profile.md`。

## 不可破坏的约束

- 不写火影解说、设定科普或长旁白。
- 不让现代行政流程成为主冲突。
- 不为凑证据链或二次打脸加入无关角色。
- 不强制每条脚本使用报告、档案、账单或 VCR。
- 不混用不兼容的角色时期和关系，除非明确是元叙事。
- 结尾不靠写检讨、宣布处罚或继续解释。
- 未核对拍摄库存时，不能声称脚本可直接低成本拍摄。
