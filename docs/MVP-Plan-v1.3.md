# 📋 MoodWhisper MVP 开发计划

基于 PRD v2.5 + UI/UX 设计文档 v1.0 + 架构设计文档 v1.0 | 架构师：Astra 🏛️ | 日期：2026-03-31

## 一、项目概况

| 项 | 内容 |
|----|------|
| 项目 | MoodWhisper（情绪记录 App） |
| 范围 | MVP（US-0 ~ US-6.1），纯本地，无后端 |
| 技术栈 | Flutter + Riverpod + sqflite + fl_chart + go_router |
| 预估工期 | 4~5 周（17~22 人天） |
| 目标平台 | iOS 14+ / Android 7+ |

## 二、阶段总览

| 阶段 | 内容 | 涉及 US | 工期 | 依赖 |
|------|------|---------|------|------|
| P0 | 项目骨架 & 基础设施 | — | 2~2.5 天 | — |
| P1 | 核心数据层 | US-1（数据侧） | 2~3 天 | P0 |
| P2 | 首页·情绪记录 | US-1 | 3~4 天 | P1 |
| P3 | 记录列表页 | US-2 | 2~3 天 | P2 |
| P4 | 统计趋势页 | US-3 | 2~3 天 | P1 |
| P5 | 设置 & 全局 | US-4/5/6/6.1 | 2.5~3 天 | P1 |
| P6 | 首次引导 | US-0 | 1 天 | P5 |
| P7 | 打磨 & 测试 | 全部 | 3~4 天 | P2~P6 |

P2/P4/P5 可以部分并行（P4/P5 只依赖 P1 数据层），但建议单人串行，避免合并冲突。

## 三、逐阶段任务拆解

### P0：项目骨架 & 基础设施（2~2.5 天）

目标：空壳能跑，路由通，主题能切，数据库能初始化，基础设施全部就位。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 0.1 | flutter create 初始化，配置 minSdk 21 / iOS 14 | 项目可编译运行 | — |
| 0.2 | 搭建目录结构（app/core/data/features/shared） | 完整空目录树 | 架构文档 §2.2 |
| 0.3 | 引入全部依赖（pubspec.yaml） | sqflite, riverpod, fl_chart, go_router, shared_preferences, csv, share_plus, flutter_local_notifications, logger, sentry_flutter | 架构文档 §3.6 |
| 0.4 | 主题系统 | theme.dart：浅色/深色 ColorToken 全部定义（含情绪色 5 组×2 模式） | UI 文档 §1.2 |
| 0.5 | 路由骨架 | go_router 配置：Onboarding → MainShell（4 Tab），Tab 页先放占位 Widget | UI 文档 §3.1 |
| 0.6 | SQLite 初始化 + 建表 | database_helper.dart：mood_records + app_settings 两张表 + 索引 | 架构文档 §5.1~5.3 |
| 0.7 | 通用常量定义 | constants/：MoodType 枚举（key/label/emoji/valence）、间距 Token、色值 Token | 架构文档 §6.2 + UI 文档 §1.2 |
| 0.8 | 字体系统配置 | 定义 H1~Caption 6 级字体 Token（sp、字重、行高），配置平台字体映射（iOS: SF Pro，Android: Roboto / Noto Sans），情绪图标统一使用 Apple Color Emoji / Noto Emoji | UI 文档 §1.3 |
| 0.9 | App Icon 配置 | 生成多尺寸 App Icon（iOS: 1024×1024 主图标 + Assets Catalog；Android: adaptive icon 前景+背景），配置到各平台工程；MVP 阶段使用占位图标，正式图标后续替换 | — |
| 0.10 | Launch Screen / Splash Screen | iOS: LaunchScreen.storyboard 带居中 Logo；Android: splash.xml / Flutter Custom Splash Screen；禁止白屏冷启动 | — |
| 0.11 | Riverpod Provider 架构落地 | main.dart 包裹 ProviderScope；定义全局 Provider（themeProvider、databaseProvider）vs 页面级 Provider 的分层规范；编写 provider_conventions.md 供后续开发参照 | 架构文档 §2.3 |
| 0.12 | 日志体系 | 引入 logger 包；定义日志等级规范（DEBUG → 开发调试、INFO → 关键操作、WARN → 可恢复异常、ERROR → 需关注错误）；统一通过 AppLogger 封装调用，禁止裸 print | — |
| 0.13 | 崩溃上报接入 | 接入 Sentry（flutter sdk），配置 DSN；未捕获异常和 Flutter 错误自动上报；Release 模式启用、Debug 模式仅日志不发送 | — |
| 0.14 | 文案集中管理（i18n 预留） | 创建 constants/strings.dart，所有 UI 文案以 static const String 形式统一存放；MVP 阶段仅中文，但架构上为未来多语言扩展预留（key 命名规范：页面_组件_用途） | — |
| 0.15 | 数据库迁移版本管理规范 | 定义 DB_VERSION 常量、onUpgrade 迁移链完整性自检（version 逐级递增，不允许跳跃）；编写 migration_conventions.md；包含 v0→v1（建表）迁移 | 架构文档 §5.3 |
| 0.16 | 签名配置 | iOS：配置 Signing Certificate + Provisioning Profile（Development & Distribution），Xcode 项目开启 Automatic Signing 或手动配置；Android：生成 Keystore 签名文件（keytool -genkey），配置 build.gradle signingConfigs，将 keystore.jks 加入 .gitignore，创建 key.properties 模板文件；确保 Debug/Release 两种 Build Configuration 均可正常签名 | — |

**交付物：** `flutter run` 能看到 4 个空 Tab 页 + App Icon + 启动屏，深色模式可切换，字体体系完整，日志/崩溃上报可用，Provider 分层规范明确，签名配置就绪。

### P1：核心数据层（2~3 天）

目标：数据库 CRUD + 统计查询全部可用，有单元测试覆盖。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 1.1 | 数据模型定义 | MoodRecord（含 uuid 字段，为 v3.0 云端同步预留）/ MoodType / StatSummary / TimeSeriesPoint / OnboardingState | 架构文档 §6.2 + §11 |
| 1.2 | MoodDao | insert / update / delete / deleteAll / queryPaged / getSummary / getDistribution / getIntensityTrend | 架构文档 §6.1 |
| 1.3 | MoodRepository | 封装 DAO + 业务逻辑（强度校验、时间回溯 ≤7天） | 架构文档 §2.3 |
| 1.4 | SettingsRepository | getThemeMode / setThemeMode / isOnboardingComplete / markOnboardingComplete / isSwipeGuided / markSwipeGuided | 架构文档 §6.1 |
| 1.5 | 单元测试 | MoodDao CRUD 测试 + 统计查询测试 ≥ 80% 覆盖 | — |
| 1.6 | UUID 生成 & 数据库迁移 | mood_records 表增加 uuid TEXT 字段（UNIQUE）；新增记录自动生成 UUID；编写 v1→v2 迁移脚本 & 测试 | 架构文档 §11 |
| 1.7 | SQLite 单例约束 & Isolate 规范 | DatabaseHelper 强制单例模式（factory constructor + static instance）；文档化约束：所有数据库操作必须在 Main Isolate 执行，禁止在后台 Isolate 中直接访问数据库；如未来引入后台任务需通过 Isolate 通信机制转发到 Main Isolate；在 database_conventions.md 中记录此约束 | 架构文档 §5 |

**关于 UUID 预留：** 架构文档 §11 明确建议"MVP 阶段为每条记录生成 UUID，为未来同步预留"。虽然 MVP 不做云端同步，但现在加一个字段成本极低（一行代码），v3.0 再补则需要数据迁移脚本 + 全量回填，风险和成本都更高。

**交付物：** `flutter test` 全绿，Repository 层可独立工作，每条记录携带 UUID，数据库单例约束明确。

### P2：首页·情绪记录（3~4 天）

目标：2 步完成记录（选情绪→保存），粒子动画 + 低端机降级。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 2.1 | EmotionButton 组件 | 5 个情绪按钮，按效价排列；选中态：放大 1.15x + spring 200ms + 边框高亮，其余 0.4 透明度；选中时触发 haptic feedback（light impact） | UI 文档 §2.1 |
| 2.2 | IntensitySlider 组件 | 5 级离散滑块，默认值 3，轨道填充情绪色 | UI 文档 §2.1 |
| 2.3 | 备注输入 + 键盘适配 | 输入框展开 → 页面上推，保存按钮 sticky bottom，键盘工具栏含"完成"；最大输入长度 500 字符，接近上限时显示字数提示（如"450/500"） | PRD US-1 |
| 2.4 | 时间修改交互 | 点击顶栏时间文字 → 系统 DateTime Picker，可选范围 ≤7 天 | PRD US-1 |
| 2.5 | 粒子保存动画 | Canvas 自绘粒子扩散；首帧 >16ms 自动降级为缩放；降级结果持久化 | 架构文档 ADR-003 |
| 2.6 | 保存逻辑串联 | 未选情绪→按钮禁用；已选→情绪色激活→点击→粒子动画→Repository 写入→界面重置；保存成功触发 haptic feedback（medium impact） | PRD US-1 |
| 2.7 | 最近记录预览区 | 首页底部展示最近 3 条，点击跳转列表页 | UI 文档 §2.1 |
| 2.8 | 空状态处理 | 无记录时显示"选择一个表情开始记录吧 👋" | UI 文档 §5.1 |
| 2.9 | 首页加载态 | 情绪图标依次淡入（每个间隔 100ms），遵循 UI 文档 §5.2 规格 | UI 文档 §5.2 |
| 2.10 | Widget 测试（首页 Smoke Test） | 情绪选择→强度调节→保存流程的 Widget 级 smoke test；验证关键 Widget 渲染、交互响应正确 | — |

**交付物：** 首页完整可用，可记录→保存→看到动画→首页刷新最近记录，核心路径有 Widget 测试覆盖。

### P3：记录列表页（2~3 天）

目标：日期分组列表 + 滑动操作 + 编辑 + 首次引导动画。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 3.1 | RecordCard 组件 | 左侧 4px 情绪色条 + 图标 + 强度圆点 + 时间 + 备注截断 | UI 文档 §2.2 |
| 3.2 | 日期分组列表 | 按天分组标题 + 时间倒序 + 上拉加载更多（每页 20 条） | PRD US-2 |
| 3.3 | 左滑删除 | 露出红色"删除"80px，点击弹出确认弹窗；确认操作触发 haptic feedback（notification warning） | UI 文档 §2.2 |
| 3.4 | 右滑编辑 | 露出蓝色"编辑"80px，点击跳转编辑页（复用 US-1 表单，预填数据） | PRD US-2 |
| 3.5 | ⋯ 更多菜单 | 浮层含"编辑记录"+"删除记录"，8px 圆角 | UI 文档 §2.2 |
| 3.6 | 手势冲突处理 | 纵向优先（先判断下拉刷新），斜向 ±30° 内不触发横向 | PRD US-2 |
| 3.7 | 下拉刷新 | 触顶下拉→情绪图标旋转→刷新完成 | UI 文档 §2.2 |
| 3.8 | 首次滑动引导动画 | 首次进入：右滑→回→左滑→回，底部文字提示"左滑可删除，右滑可编辑" 3s 淡出 | PRD US-2 |
| 3.9 | 编辑页 | 复用 US-1 表单，预填已有数据；时间选择器允许修改但不超 7 天限制（从当前时间往前推算，已保存的记录时间也受此约束）；保存后返回列表 Toast"已更新 ✅" | PRD US-2 |
| 3.10 | 空状态 | "还没有记录哦～去记录第一个情绪吧 😊"+"去记录"按钮 | UI 文档 §5.1 |
| 3.11 | 列表加载骨架屏 | 首次加载显示骨架屏：3 条灰色矩形模拟卡片（200ms 脉冲闪烁动画）；上拉加载更多时底部显示 24px spinner | UI 文档 §5.2 |
| 3.12 | Widget 测试（列表 Smoke Test） | 列表渲染、左滑删除、右滑编辑的 Widget 级 smoke test；验证滑动方向判定、删除确认弹窗交互 | — |

**交付物：** 列表页完整可用，增删改查闭环，加载态体验流畅，滑动操作有 Widget 测试覆盖。

### P4：统计趋势页（2~3 天）

目标：渐进披露，统计摘要 + 情绪分布 + 强度趋势，数据不足折叠。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 4.1 | 时间范围 Tab | 7天 / 30天 / 全部，切换图表平滑过渡 300ms | UI 文档 §2.3 |
| 4.2 | 统计摘要卡片 | 2×2 网格：平均强度 / 最频繁情绪 / 记录总数 / 记录天数，下方"平均每天 X.X 条" | PRD US-3 |
| 4.3 | 情绪分布环形图 | fl_chart RingChart，直径 160px，环宽 24px，扇区间隔 2px；点击扇区高亮 + 中心显示占比 | UI 文档 §2.3 |
| 4.4 | 强度趋势折线图 | fl_chart LineChart，180px 高，线宽 2.5px + 20% 透明填充；长按弹出 Tooltip | UI 文档 §2.3 |
| 4.5 | 数据不足折叠 | <7 天记录时折叠图表区域（环形图 + 折线图），显示"记录更多天后解锁趋势分析"+ 进度条 X/7；统计摘要卡片不折叠，始终展示已有数据的统计结果 | PRD US-3 |
| 4.6 | 图表加载骨架屏 | 数据加载中显示灰色区域 + 脉冲动画；加载失败显示"加载失败"+ 重试按钮 | UI 文档 §5.2 + §5.3 |

**交付物：** 统计页完整可用，7/30/全部切换正常，数据不足时图表折叠但摘要卡片始终可见，加载态 & 错误态完整。

### P5：设置 & 全局功能（2.5~3 天）

目标：深色模式 + 数据导出 + 数据清空 + 每日提醒通知 + Tab Bar 壳 + "我的"页。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 5.1 | Tab Bar 壳 | MainShellPage：4 等宽 Tab（记录/列表/统计/我的），56px + 安全区，选中态 accent 色 | UI 文档 §3.1 |
| 5.2 | "我的"页面布局 | 外观 / 数据 / 帮助 / 关于 4 个分组，行高 56px | UI 文档 §2.4 |
| 5.3 | 深色模式切换 | Toggle 开关 + 跟随系统选项，切换整页过渡 300ms，所有页面适配 | PRD US-5 |
| 5.4 | CSV 数据导出 | csv 库生成 + share_plus 调用系统分享；空数据 Toast"暂无记录可导出"，失败 Toast"导出失败，请重试"；导出文件名格式：MoodWhisper_YYYYMMDD.csv | PRD US-4 |
| 5.5 | 清空数据 | 红色弹窗 + 输入"清空"激活确认按钮 + 不可撤销；清空后同时重置 onboarding 状态（SharedPreferences 中 isOnboardingComplete 标记重置，下次启动进入引导流程） | PRD US-6 |
| 5.6 | Toast 通用组件 | 顶部居中，滑入 200ms → 停留 2s → 滑出 200ms | UI 文档 §3.2 |
| 5.7 | 开源许可页面 | "关于"区域"开源许可 →"入口，展示 Flutter 及所有依赖库的 License 列表（可使用 Flutter 内置 showLicensePage） | UI 文档 §2.4 |
| 5.8 | 隐私政策页面 | "关于"区域"隐私政策 →"入口，展示本地隐私政策说明页（静态内容：数据完全本地存储、不上传、不收集） | UI 文档 §2.4 |
| 5.9 | 版本信息展示 | "关于"区域显示"MoodTracker v1.0.0" | UI 文档 §2.4 |
| 5.10 | 通知权限请求 | 调用 flutter_local_notifications 请求通知权限；iOS 请求 UNUserNotificationCenter 权限；Android 请求 POST_NOTIFICATIONS（Android 13+）；用户拒绝后下次打开不再弹窗，仅在设置页提示"请在系统设置中开启通知" | PRD US-6.1 |
| 5.11 | 本地通知调度 | 使用 flutter_local_notifications 注册每日定时通知；支持自定义提醒时间（默认 21:00）；通知内容："今天过得怎么样？记录一下你的心情吧 😊"；支持 cancel/reschedule | PRD US-6.1 |
| 5.12 | 提醒时间设置 UI | "我的"页 → 外观分组 → "每日提醒"：Toggle 开关 + 时间选择器（点击弹出 TimePicker）；开关关闭时隐藏时间选择；设置持久化到 SharedPreferences | PRD US-6.1 |
| 5.13 | 提醒开关 & 状态管理 | ReminderProvider（Riverpod）：管理开关状态 + 提醒时间 + 通知调度；App 启动时检查开关状态，重新注册通知（防止重启后丢失）；导出/清空数据不影响提醒设置 | PRD US-6.1 |

**交付物：** Tab Bar 完整，"我的"页全部功能可用，关于区域完整，每日提醒通知可设置并可正常触发，清空数据后 onboarding 正确重置。

### P6：首次引导（1 天）

目标：3 页引导卡片，首次判断逻辑，可重播。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 6.1 | 3 页引导卡片 | PageView：记录情绪 → 查看趋势 → 隐私承诺，每页插图 + 文案 + 指示器 | UI 文档 §2.0 |
| 6.2 | 跳过 & 下一步 & 开始使用 | 右上角"跳过"，前两页"下一步"，第 3 页"开始使用"（accent 色） | PRD US-0 |
| 6.3 | 首次判断逻辑 | 首次打开→引导；已完成→跳转 MainShell；标记持久化到 SharedPreferences | PRD US-0 |
| 6.4 | 重播入口 | "我的"页"使用引导"→跳转 Onboarding | PRD US-0 |
| 6.5 | 过渡动画 | 左右滑动 ≤300ms ease-in-out | UI 文档 §2.0 |

**交付物：** 首次安装→引导流程→主页面；"我的"页可重播引导。

### P7：打磨 & 测试（3~4 天）

目标：深色模式全量适配 + 动效微调 + 边界状态 + 真机测试 + 集成测试 + 应用商店素材。

| # | 任务 | 产出 / 验收标准 | 参考 |
|---|------|-----------------|------|
| 7.1 | 深色模式全量检查 | 逐页对比深色色值（独立情绪色变体、背景 #121212 / #1E1E1E / #2C2C2C）；折线图填充深色模式 30% 透明度；Toast / Tab Bar 深色适配 | UI 文档 §4 |
| 7.2 | 空状态 & 错误态 & 加载态巡检 | 所有页面的空状态、加载态（骨架屏）、错误态按 UI 文档 §5 实现到位 | UI 文档 §5 |
| 7.3 | 响应式适配（竖屏） | iPhone SE (375px) ~ Pro Max (430px) + Android 360px 小屏缩放 | UI 文档 §6 |
| 7.4 | 横屏策略：MVP 锁竖屏 | MVP 阶段强制竖屏锁定（Android: AndroidManifest 设置 screenOrientation="portrait"；iOS: Info.plist 设置 Supported interface orientations 仅 Portrait）；横屏适配记入 v2.0 backlog，不在 MVP 范围内 | UI 文档 §6 |
| 7.5 | 无障碍基础 | 语义化 aria-label / Focus 环 / 字体缩放至 200% 不崩 / prefers-reduced-motion | UI 文档 §7 |
| 7.6 | 性能验证 | 冷启动 <2s / 保存 <500ms / 图表加载 <1s / 列表 60fps | 架构文档 §9 |
| 7.7 | 真机测试（iOS） | Release 模式，至少 iPhone SE + iPhone 14 级别 | — |
| 7.8 | 真机测试（Android） | Release 模式，至少小屏 360px + 大屏 412px | — |
| 7.9 | 崩溃率 & 稳定性 | 通过 Sentry Dashboard 监控崩溃率 <0.1%；无已知必崩路径；修复所有 P0/P1 级别 crash | PRD 验收标准 |
| 7.10 | Integration Test（端到端） | 编写至少 1 条核心路径端到端测试：记录情绪 → 列表页可见 → 统计页数据出现；使用 integration_test 包在真机/模拟器上执行；验证关键用户旅程的数据流转完整性 | — |
| 7.11 | 应用商店素材准备 | 准备 App Store Connect / Google Play Console 所需素材：应用截图（iOS 6.7"/6.5"/5.5" 各一组，Android 手机+平板各一组）、应用描述（中英文）、关键词（iOS）、应用分类、内容分级问卷、隐私政策 URL（可使用 GitHub Pages 托管本地隐私政策文档） | — |

**交付物：** MVP 验收标准全部通过，端到端集成测试通过，应用商店素材齐备，可提审。

## 四、依赖关系图

```
P0 项目骨架（含 Provider 架构 / 日志 / 崩溃上报 / App Icon / Launch Screen / 签名配置 / 迁移规范）
├── P1 数据层（含 UUID 预留 / SQLite 单例约束）
│    ├── P2 首页·情绪记录
│    │    └── P3 记录列表页
│    ├── P4 统计趋势页
│    └── P5 设置 & 全局（含 US-6.1 每日提醒通知）
│         └── P6 首次引导
└── P7 打磨 & 测试（含 Integration Test / 应用商店素材）← P2~P6 全部完成后执行
```

关键路径：P0 → P1 → P2 → P3 → P7（约 12~15 天）
非关键路径：P4 / P5 可与 P2/P3 并行（如果有协作者）

## 五、里程碑 & 验收节点

| 节点 | 时间 | 验收内容 |
|------|------|----------|
| M1 - 数据层就绪 | 第 1 周末 | 单元测试全绿，CRUD + 统计查询可用，UUID 字段就位，SQLite 单例约束明确 |
| M2 - 核心功能闭环 | 第 2 周末 | US-1 记录 + US-2 列表 + US-3 统计 可操作 |
| M3 - MVP 功能完成 | 第 3 周末 | US-0~US-6.1 全部实现，深色模式可用，关于页面完整，每日提醒可触发 |
| M4 - 验收通过 | 第 4 周末 | 真机测试通过，性能达标，Sentry 崩溃率 <0.1%，签名配置就绪，应用商店素材齐备，Integration Test 通过，可提审 |

## 六、风险与注意事项

| 风险 | 缓解 |
|------|------|
| 粒子动画低端机卡顿 | ADR-003 帧率检测 + 自动降级，P2 阶段优先验证 |
| 深/浅双主题维护成本 | P0 阶段建立 ColorToken 体系，杜绝硬编码色值 |
| 个人开发精力不足 | 严格 MVP 范围控制：US-7~US-15 坚决不做 |
| Flutter 热重载掩盖真机问题 | P7 必须在 Release 模式真机验证 |
| SQLite 迁移兼容性 | P0 定义迁移版本管理规范，P1 补充迁移测试 |
| 横屏适配工期超预期 | MVP 强制锁竖屏，横屏适配为 v2.0 backlog |
| iOS 通知权限被拒 | 引导页说明通知用途，拒绝后不在设置页弹窗，仅提示去系统设置开启 |
| Android 通知渠道兼容 | flutter_local_notifications 需配置 NotificationChannel（Android 8.0+），P5 阶段优先验证 |
| iOS 签名证书过期/配置错误 | P0 阶段提前配置签名，确保 CI/CD 可正常打包；Distribution 证书注意有效期 |
| 应用商店审核被拒 | P7 准备完整商店素材；隐私政策页面必须有（P5.8）；数据清空功能必须有（P5.5）；确保不收集用户数据的承诺与实际行为一致 |

## 七、v2.0 Backlog（MVP 不做，明确记录）

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 横屏适配 | 双栏布局、Tab Bar 侧边化 | P2 |
| 多语言（i18n） | 文案已集中管理，接入 flutter_localizations 即可 | P2 |
| Widget 测试全覆盖 | MVP 仅有 smoke test，后续补充完整 Widget 测试 | P1 |
| 集成测试全覆盖 | MVP 仅有 1 条核心路径 E2E，后续补充更多场景 | P2 |
| CSV 导出加密 | 明文导出存在隐私风险，v2.0 增加可选密码加密 | P1 |
| Haptic feedback 全量优化 | MVP 仅覆盖选中/保存/删除，后续补充更多触觉反馈场景 | P3 |

---

文档版本：v1.3 | 基于 PRD v2.5 + UI/UX v1.0 + 架构 v1.0 | 架构师：Astra 🏛️

v1.3 更新（2026-04-05）：根据 Code Review 反馈补充——签名配置（P0.16）、SQLite 单例约束（P1.7）、备注字数限制 500 字（P2.3）、编辑页时间选择器 7 天限制（P3.9）、数据不足时摘要卡片不折叠（P4.5）、清空数据后重置 onboarding（P5.5）、Integration Test 端到端（P7.10）、应用商店素材准备（P7.11）、CSV 导出加密加入 v2.0 Backlog、签名/审核风险项。
