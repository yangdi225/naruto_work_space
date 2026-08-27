# 脚本反馈闭环 V2

## 目标

让工作流从用户判断和发布数据中学习，不再只依赖生成器自评。

## 三类记录

### 生成记录
写入 `knowledge/topic-pool.csv`：候选、淘汰原因、组件组合、对应脚本和当前状态。

### 人工评价
写入 `knowledge/script-evaluations.csv`：

- `user_label`：默认只要求填写 `保留 / 一般 / 无聊 / 奇怪`。
- `naturalness`：角色行为是否自然，1-5。
- `benchmark_feel`：是否像对标节奏，1-5。
- `funniest_line`：最好笑的一句。
- `weirdest_line`：最奇怪的一句。
- `decision`：保留、改写、淘汰、待评价。

四标签是必需的最小反馈；其余字段均为可选。人工评价优先级高于脚本自评分。

### 发布反馈
已发布后补充播放、完播率、点赞率、评论率和高频评论。没有真实数据时留空，不能用“预计表现”代替。

## 公式复盘

- 连续 3 条被评价“机械”的组件组合暂停使用。
- 某个旧 F 公式使用率超过最近 10 条脚本的 40%，下一批候选降低优先级。
- 复盘先比较冲突组件、火影载体和收尾机制，再比较角色，不用单次数据直接下永久结论。

## 口味画像复盘

- 每累计 5 条有 `user_label` 的评价，复盘一次 `knowledge/taste-profile.md`。
- 单次负反馈只记录假设，不立即升级为永久规则。
- 连续 3 条为 `无聊` 或 `奇怪` 时才启动人工冷开场校准。
- 单条失败记录机制，下一次生产禁用同类；不在当前请求内继续生成长稿，也不要求用户定位具体台词。

## 状态流转

`candidate -> shortlisted -> scripted -> needs_rewrite -> shoot_ready -> shot -> published`

淘汰项使用 `rejected`，并保留淘汰原因。只有通过硬质检且人工决定保留的脚本才能进入 `shoot_ready`。

`script-evaluations.csv` 的自动校验状态单独使用 `hard_check_failed` 或 `hard_check_passed`；它描述机器检查结果，不替代上面的创作状态。
