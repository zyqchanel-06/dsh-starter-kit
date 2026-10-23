# DSH 新手整合包

刚装上 DeepSeek Harness，打开对话框却不知道让它干什么？这个包把**能让 AI 变好用**的技能按需求打包好了，选一个套餐装进去就行。

> 技能（skill）不是插件。它不增加工具，只教 AI「遇到这类事先想什么、按什么步骤做」。装对了技能，AI 写出来的东西明显不像套模板。

---

## 先选一个套餐

| 你是 | 选这个 | 会得到什么 |
| --- | --- | --- |
| 写公众号 / 小红书 / 脚本 / 文案 | **writer** | 去 AI 味、润色、提示词写作、先想清楚再动笔 |
| 用 AI 写代码、维护小项目 | **coder** | 测试驱动、代码审查、调试方法、并行任务 |
| 做资料研究 / 读书 / 做 PPT | **researcher** | 证据优先的深读、PPT 生成、英文润色 |
| 不确定 / 想全都试试 | **everything** | 上面全部 |

```powershell
# 看所有套餐
powershell -ExecutionPolicy Bypass -File .\install.ps1 -List

# 装（把 writer 换成你选的）
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Preset writer
```

装完**新开一个会话**，直接问 AI「你现在有哪些技能」就能验证。

---

## 这个包解决什么问题

DSH 开箱已经带齐了工具：读写文件、跑命令、联网搜索、子代理都在。新手真正缺的不是工具，是**工作方法**。

同样一句「帮我加个功能」：

- 没有技能：AI 直接改代码，改完说「好了」，你也不知道它测没测过。
- 装了 coder 套餐：它会先问清楚需求（brainstorming）→ 写实施计划（writing-plans）→ 先写测试（test-driven-development）→ 改完自己验证（verification-before-completion）。

差别不在 AI 聪不聪明，在**有没有一套流程约束它**。

---

## 四个套餐里都有什么

### writer · 写作 / 内容创作者

| 技能 | 干什么 |
| --- | --- |
| de-ai-writing | 去掉中文的 AI 味：解构式转折、装饰性状语、空泛排比 |
| humanizer-zh | 润色中文空话、重复、模板化表达 |
| shuorenhua | 审稿或去 AI 味，可只标问题不改写 |
| stop-slop | 清除英文的 AI 写作痕迹 |
| writing-prompts | 把模糊需求打磨成精确、可直接用的提示词 |
| writing-skills | 自己动手写一个新技能 |
| huashu-nuwa | 输入一个人名，蒸馏出「他会怎么想」的思维技能 |
| + 4 个通用 | brainstorming / writing-plans / verification / using-superpowers |

### coder · 编程 / 开发者

| 技能 | 干什么 |
| --- | --- |
| test-driven-development | 先写测试再写实现 |
| requesting-code-review | 让 AI 以审查者视角挑自己的毛病 |
| receiving-code-review | 收到审查意见先核实，不盲从 |
| systematic-debugging | 四阶段定位法，禁止瞎猜式修复 |
| using-git-worktrees | 开独立工作区，不污染主分支 |
| finishing-a-development-branch | 收尾：合并 / PR / 丢弃 |
| dispatching-parallel-agents | 多个独立任务并行分派 |
| subagent-driven-development | 用子代理执行实施计划 |
| + 5 个通用 | 同上 |

### researcher · 研究 / 学习 / 出图

| 技能 | 干什么 |
| --- | --- |
| dsh-deepread | 精读长文/书：核心观点、论证结构、证据溯源、置信度分级 |
| ppt-master | 生成可编辑的 PPTX（**体积大 41MB，本包未收录**，需要的话单独装） |
| humanizer | 英文写作去 AI 味 |
| writing-prompts | 提示词打磨 |
| + 4 个通用 | 同上 |

### everything · 我全都要

上面所有技能（23 个）+ 5 个推荐插件。

---

## 插件（可选，不是必须）

插件才是真正「加功能」的东西。以下都是第三方项目，**本包不打包它们的代码**，装之前请自己看一眼作者说明：

| 插件 | 效果 |
| --- | --- |
| DeepSeek-Balance-Whale-Widget | 桌角一只鲸鱼，显示 API 余额 |
| dsh-ui-wallpaper | 换聊天背景壁纸 |
| dsh-rail-x | 增强侧栏 |
| dsh-status-rotator | 状态栏轮播关键信息 |
| dsh-deep-whale | 主题换肤 |

安装方式取决于插件作者，通常在 DSH 的插件管理界面按包名搜索，或按作者 README 操作。

---

## 装在哪里 / 怎么卸载

技能默认装到 `%USERPROFILE%\.dsh\skills`（全局生效）。也可以用 `-Scope Project` 只装到某个项目。

**卸载就是删目录**：

```powershell
Remove-Item "$env:USERPROFILE\.dsh\skills\brainstorming" -Recurse
```

技能是纯文本（Markdown），没有后台进程、不联网、不改系统设置。

---

## 常见问题

**装完没反应？** 新开一个会话再说一句话。DSH 支持热加载，但最保险是重开会话。

**怎么知道装成功了？** 问 AI「列出你现在可用的技能」，或者看 `%USERPROFILE%\.dsh\skills` 目录。

**会不会和我已有的技能冲突？** 同名技能默认跳过。要强制覆盖加 `-Force`。

**这些技能是你们写的吗？** 不是全部，来源见下。

---

## 来源与许可

本包是**索引 + 安装器**，技能内容来自多个上游项目：

- brainstorming / writing-plans / executing-plans / test-driven-development / systematic-debugging / requesting-code-review / receiving-code-review / using-git-worktrees / finishing-a-development-branch / dispatching-parallel-agents / subagent-driven-development / using-superpowers / verification-before-completion / writing-skills —— 来自 Superpowers 技能集
- humanizer —— 基于 Wikipedia《Signs of AI writing》
- humanizer-zh / shuorenhua / de-ai-writing / stop-slop —— 中文写作社区整理
- dsh-deepread / ppt-master / writing-prompts / huashu-nuwa —— 本仓库整理

各技能目录内保留原有 LICENSE。发现授权问题请开 Issue。

本包自身的安装脚本与文档：MIT。

---

## 免责

技能是**给 AI 的建议**，不是绝对正确的规则。涉及法律、医疗、财务、安全的内容，最终判断权在你。