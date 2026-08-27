# naruto-vrchat-script-workflow

把搞笑配音对标拆成可复用节奏和公式组件，再通过候选赛制生成、筛选、质检和复盘火影 VRChat 沙雕短视频脚本。

核心原则：不是讲火影，而是让火影角色在原著关系和能力逻辑里当场冲突，并能用 VRChat 正反打拍出来。

## V4 故事先行自动驾驶

- 先确立“具体欲望 -> 错误执行 -> 两次行动升级 -> 可见结算”，再用公式记录来源。
- 读取真实反馈形成 `knowledge/taste-profile.md`，区分稳定偏好和暂定假设。
- 默认内部生成 5 个事件前提，筛到 2 条行动阶梯，只扩写 1 个完整事件版冠军。
- 默认不保存长篇候选赛记录；明确要求深度筛选时才使用 12 选 4 选 2。
- 故事红队不读取自评分、标题和创作解释，也不再用百分制或固定结构证明好笑。
- 红队增加严肃同人测试，伤感、锋利或正确但没有荒唐行为的句子不能当作喜剧峰值。
- 默认先完成 60-90 秒的可升级事件；20-40 秒短稿只能从完整事件剪出。
- 拍摄可行性以真实 Avatar、地图和道具库存为准。
- 新增 PowerShell 硬质检器，校验时长、时间轴、镜头数、角色数和质检结论。
- 用户默认只反馈 `保留 / 一般 / 无聊 / 奇怪`；连续 3 条负反馈才重新进入人工校准。

## 目录

```text
naruto-vrchat-script-workflow/
├─ .agents/skills/naruto-vrchat-script/
│  ├─ SKILL.md
│  ├─ references/
│  │  ├─ account-positioning.md
│  │  ├─ benchmark-analysis-rules.md
│  │  ├─ benchmark-style-writing-rules.md
│  │  ├─ formula-components.md
│  │  ├─ formula-library.md
│  │  ├─ candidate-selection-rules.md
│  │  ├─ comedy-intensity-rules.md
│  │  ├─ autopilot-workflow.md
│  │  ├─ comedy-red-team.md
│  │  ├─ expansion-regression-rules.md
│  │  ├─ topic-quality-rules.md
│  │  ├─ character-profiles.md
│  │  ├─ character-behavior-credibility.md
│  │  ├─ character-voice-bank.md
│  │  ├─ production-inventory-rules.md
│  │  ├─ quality-checklist.md
│  │  └─ feedback-loop.md
│  └─ templates/
├─ knowledge/
│  ├─ benchmark-scripts.md
│  ├─ analyzed-benchmarks.md
│  ├─ topic-pool.csv
│  ├─ production-inventory.csv
│  ├─ script-evaluations.csv
│  ├─ comedy-calibrations.csv
│  ├─ taste-profile.md
│  ├─ historical-scripts.md
│  ├─ script-retrospectives.md
│  └─ validation-baseline.md
├─ prompts/00-06
├─ scripts/
│  ├─ validate-script.ps1
│  └─ test-validator.ps1
├─ tests/fixtures/
└─ outputs/scripts/
```

## 第一次使用前

先编辑 `knowledge/production-inventory.csv`，把实际拥有的 Avatar、地图、道具和特效标成：

- `available`：可直接使用。
- `substitute`：已有明确替代。
- `unknown`：尚未确认。
- `blocked`：当前不可用。

库存没有确认前，工作流不会把相关选题判为“低成本可直接拍”。

## 添加和拆解对标

1. 把原始台词或摘要追加到 `knowledge/benchmark-scripts.md`，分配 B 编号。
2. 使用 `prompts/01-benchmark-analyzer.md` 测量钩子、轮数、句长、打脸位置和结尾机制。
3. 把结果追加到 `knowledge/analyzed-benchmarks.md`。
4. 使用 `prompts/02-formula-extractor.md` 映射或新增 C/N/P 组件。

重点迁移节奏关系，不复制对标固定台词。

## 生成选题

日常生产直接使用 `prompts/00-autopilot-pipeline.md`。工作流会读取口味画像、已有选题、用户反馈和拍摄库存：

1. 内部生成 5 个荒唐事件前提，至少淘汰 3 个。
2. 两强各写“错误执行 -> 升级一 -> 升级二 -> 可见结算”行动阶梯。
3. 故事红队只选一个冠军，并执行严肃同人测试。
4. 扩写为 60-90 秒完整事件并做行动损耗检查。
5. 制作正式 VRChat 分镜并运行一次严格校验；需要时再剪短版。

候选、淘汰原因和状态写入 `knowledge/topic-pool.csv`。

单条脚本被评价无聊或奇怪时，工作流记录失败机制，并在下一次生产中禁用同类，不在当前请求内继续生成长稿。只有最近连续 3 条负反馈，或用户明确要求校准时，才展示 6 条冷开场重新校准口味。

## 生成脚本

使用 `prompts/04-script-generator.md` 和 `.agents/skills/naruto-vrchat-script/templates/script-output-template.md`。只扩写行动阶梯冠军，检查错误执行、两次行动升级、可见结算与喜剧负载，再制作 VRChat 分镜。默认先完成完整事件版。

保存后运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-script.ps1 -Path outputs/scripts/Sxxx-file.md -Strict
```

硬错误不为 0 时先改写，不能标记通过。

## 质检和改写

使用 `prompts/05-script-quality-checker.md` 做裸台词红队。质检员看不到标题、公式、自评分和胜出理由，先预测结尾，再标记新信息、主动权转移、峰值和可删台词。

需要修改时使用 `prompts/06-script-rewriter.md`，改完重新运行硬质检器。

运行校验器自动测试：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-validator.ps1
```

## 反馈闭环

看完脚本后，最低只需把一个四标签写入 `knowledge/script-evaluations.csv` 的 `user_label`：

- `保留`
- `一般`
- `无聊`
- `奇怪`

自然度、对标味、最好笑台词和最奇怪台词仍可记录，但不再要求每次填写。每累计 5 条人工评价，集中复盘一次口味画像。

发布后再补播放、完播率、点赞率和评论率。只有硬质检通过且人工决定保留的脚本，才能进入 `shoot_ready`。
