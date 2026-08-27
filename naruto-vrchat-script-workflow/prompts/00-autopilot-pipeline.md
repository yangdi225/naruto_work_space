# Prompt 00 - 故事先行自动驾驶入口 V4

目标：内部完成事件竞争、行动阶梯、故事红队和硬质检，只向用户交付一个完整事件版冠军。

## 必须读取

- `.agents/skills/naruto-vrchat-script/SKILL.md`
- `knowledge/taste-profile.md`
- `knowledge/topic-pool.csv`
- `knowledge/script-evaluations.csv`
- `knowledge/production-inventory.csv`
- `.agents/skills/naruto-vrchat-script/references/autopilot-workflow.md`

## 执行

1. 使用 Prompt 03 内部生成 5 个事件候选并筛出 2 条行动阶梯。
2. 使用故事红队只选择 1 个冠军；必须通过错误执行、两次行动升级、可见结算和严肃同人测试。
3. 使用 Prompt 04 扩写冠军为 60-90 秒完整事件版，并执行事件损耗检查。
4. 为冠军制作正式 VRChat 分镜并运行一次严格校验；用户要求时再给短剪版。
5. 如台词冗余，使用 Prompt 06 压缩一次；仍失败则标记 `needs_rewrite` 并停止。
6. 生成时只更新冠军选题和待评价脚本记录；收到用户标签后再写复盘与历史结论。

默认不创建完整候选赛 Markdown。用户明确要求深度筛选或候选审计时才使用 12 选 4 选 2。

## 面向用户的输出

- 只给冠军脚本链接、时长、角色数、镜头数和最大风险。
- 不展示内部候选、内部评分或长篇创作解释。
- 只请求一个四标签反馈：`保留 / 一般 / 无聊 / 奇怪`。
- 用户明确要求看候选或审稿细节时再展开。
