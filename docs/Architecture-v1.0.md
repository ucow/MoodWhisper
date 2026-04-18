# 🏗️ MoodWhisper 架构设计文档 v1.0

🏗️ MoodWhisper 架构设计文档 v1.0
基于 PRD v2.5 + UI/UX 设计文档 v1.0 | 架构师：Astra 🏛️ | 日期：2026-03-29

## 1. 需求理解

MoodWhisper 是一个隐私优先的移动端情绪记录应用，核心价值是"3秒完成记录 + 完全本地存储"。MVP 阶段不需要后端服务，纯本地 App，单机运行。

本质：一个带可视化能力的本地日记本，不是 SaaS，不是社交平台。

## 2. 架构设计

### 2.1 架构类型

**移动端单体应用（Mobile Monolith）**

MVP 阶段采用 Flutter 单工程单体架构，不引入任何服务端组件。所有数据存储在设备本地，无网络依赖。

理由：
- 个人开发，无服务器运维成本
- PRD 明确"无需网络即可使用"
- 数据量极小（个人情绪记录），不存在性能瓶颈
- 最小化复杂度，聚焦产品体验

### 2.2 模块划分

```
lib/
├── app/                          # 应用入口与全局配置
│   ├── main.dart                 # 入口
│   ├── router.dart               # 路由管理
│   └── theme.dart                # 主题系统（浅色/深色）
│
├── core/                         # 核心基础设施
│   ├── constants/                # 常量（情绪定义、色值、间距）
│   ├── extensions/               # Dart 扩展方法
│   └── utils/                    # 工具类（时间、格式化、导出）
│
├── data/                         # 数据层
│   ├── models/                   # 数据模型（纯实体）
│   │   ├── mood_record.dart
│   │   ├── mood_type.dart
│   │   └── onboarding_state.dart
│   ├── repositories/             # 仓库层（封装数据操作）
│   │   ├── mood_repository.dart
│   │   └── settings_repository.dart
│   └── datasources/              # 数据源
│       ├── local/
│       │   ├── database_helper.dart   # SQLite 初始化与迁移
│       │   └── dao/
│       │       └── mood_dao.dart
│       └── export/
│           └── csv_exporter.dart
│
├── domain/                       # 领域层（可选，MVP 可简化）
│   └── usecases/                 # 业务用例
│       ├── record_mood.dart
│       ├── get_statistics.dart
│       └── export_data.dart
│
├── features/                     # 功能模块（按页面/功能划分）
│   ├── onboarding/               # US-0 首次引导
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── bloc/                 # 或 provider/riverpod
│   ├── record/                   # US-1 情绪记录
│   │   ├── pages/
│   │   ├── widgets/
│   │   │   ├── emotion_button.dart
│   │   │   ├── intensity_slider.dart
│   │   │   └── particle_animation.dart
│   │   └── bloc/
│   ├── record_list/              # US-2 记录列表
│   │   ├── pages/
│   │   ├── widgets/
│   │   │   ├── record_card.dart
│   │   │   └── swipe_guide.dart
│   │   └── bloc/
│   ├── statistics/               # US-3 统计趋势
│   │   ├── pages/
│   │   ├── widgets/
│   │   │   ├── stat_summary.dart
│   │   │   ├── emotion_pie_chart.dart
│   │   │   └── intensity_line_chart.dart
│   │   └── bloc/
│   ├── export/                   # US-4 数据导出
│   ├── settings/                 # US-5/US-6 设置/深色/清空
│   │   ├── pages/
│   │   └── widgets/
│   └── main_shell/               # Tab Bar 壳
│       └── pages/
│           └── main_shell_page.dart
│
└── shared/                       # 共享组件
    ├── widgets/                  # 通用 Widget（Toast、按钮等）
    └── animations/               # 通用动画
```

### 2.3 数据流

```
UI (Widget)
    ↕ 状态管理 (Riverpod/Bloc)
Repository (业务逻辑封装)
    ↕
DAO (数据访问对象)
    ↕
SQLite (sqflite)
```

数据流采用单向数据流：
UI 发起操作 → 调用 Repository
Repository 执行业务逻辑 → 调用 DAO
DAO 操作 SQLite → 返回结果
结果通过状态管理回传 UI → Widget 重建

## 3. 技术选型

### 3.1 后端：无（纯本地应用）

MVP 阶段不需要后端。所有数据存储在设备本地 SQLite 数据库。

理由：
- PRD 明确"无需网络即可使用"+"完全本地存储"
- 个人开发无法承担服务器运维成本
- v3.0 才考虑云端同步（可选）

### 3.2 前端：Flutter

| 选项 | 理由 |
|------|------|
| ✅ Flutter | PRD 明确提及；一套代码 iOS + Android；UI 设计文档中的组件规格可直接映射到 Widget；个人开发效率最高 |
| ❌ React Native | PRD 未提及，生态与 Flutter 各有优劣，但无明确理由替换 |
| ❌ 原生双端 | 成本翻倍，个人开发不可行 |

### 3.3 数据库：SQLite (sqflite)

| 选项 | 理由 |
|------|------|
| ✅ sqflite | Flutter 生态最成熟的本地数据库；PRD 推荐；支持结构化查询（统计页需要）；数据量极小无性能顾虑 |
| ❌ Hive | KV 存储，统计查询不便 |
| ❌ Isar | 过度设计，MVP 不需要 |
| ❌ SharedPreferences | 仅适合简单 KV，不适合结构化数据 |

### 3.4 状态管理：Riverpod (推荐) / Bloc (备选)

| 选项 | 理由 |
|------|------|
| ✅ Riverpod 2.x | 编译时安全、依赖注入、测试友好；Flutter 社区推荐趋势；适合中等复杂度应用 |
| ⬜ Bloc | 更严格的单向数据流、模板化；团队熟悉时优先 |

推荐 Riverpod，但如果开发者更熟悉 Bloc 的 Event→State 模式，Bloc 完全可行。

### 3.5 图表库：fl_chart

| 选项 | 理由 |
|------|------|
| ✅ fl_chart | PRD 推荐；Flutter 原生；支持折线图、饼图/环形图；社区活跃 |
| ❌ syncfusion_flutter_charts | 功能更强但包体积大、商业授权限制 |
| ❌ charts_flutter | Google 官方但已停止维护 |

### 3.6 其他依赖

| 组件 | 选型 | 理由 |
|------|------|------|
| 路由 | go_router | Flutter 官方推荐，声明式路由 |
| 本地存储（设置项） | shared_preferences | 简单 KV（深色模式偏好、引导状态） |
| 数据导出 | csv + share_plus | CSV 生成 + 系统分享 |
| 动画 | Flutter 内置 + 自定义 | 粒子效果用 Canvas 自绘，无需额外库 |
| 国际化 | flutter_localizations | MVP 暂不需要，预留接口 |

## 4. 方案对比

### 4.1 推荐方案：Flutter + Riverpod + sqflite（轻量单体）

优点：
- 单工程、零运维、开发效率最高
- 一套代码双端发布
- 完全离线，隐私天然保证
- 技术复杂度最低，个人可维护

缺点：
- 云端同步需 v3.0 重新设计数据层
- Flutter 包体积偏大（Release 约 10-15MB）
- 深层嵌套 Widget 可能影响可读性（靠架构约束缓解）

### 4.2 备选方案：Flutter + Bloc + Isar

与推荐方案差异：
- 状态管理换 Bloc：更模板化、更适合大团队，但个人开发略显冗余
- 数据库换 Isar：性能更强（无需 SQL），但增加学习成本，MVP 阶段无必要

不选理由： MVP 阶段不需要 Isar 的性能优势，Bloc 的模板代码量对个人开发有额外负担。

### 4.3 备选方案（不推荐）：Flutter + 云端后端

引入 .NET WebAPI + SQL Server 后端，数据走网络。

不选理由： 违反 PRD "无需网络即可使用"的核心约束；个人开发运维成本不可接受；v3.0 才考虑云端同步。

## 5. 数据库设计

### 5.1 核心表

**mood_records（情绪记录表）**

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INTEGER | PK, AUTOINCREMENT | 自增主键 |
| mood_type | TEXT | NOT NULL | 情绪类型：happy/calm/sad/angry/anxious |
| intensity | INTEGER | NOT NULL, CHECK(1-5) | 强度 1-5，默认 3 |
| note | TEXT | | 文字备注，可为空 |
| recorded_at | TEXT | NOT NULL | ISO 8601 时间戳（可回溯7天内） |
| created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | 实际创建时间 |
| updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | 最后更新时间 |

**app_settings（应用设置表）**

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| key | TEXT | PK | 设置键 |
| value | TEXT | NOT NULL | 设置值（JSON 序列化） |

预置设置项：
- `theme_mode`：light / dark / system（默认 system）
- `onboarding_completed`：bool（默认 false）
- `list_swipe_guided`：bool（默认 false）

### 5.2 索引设计

```sql
CREATE INDEX idx_mood_records_recorded_at ON mood_records(recorded_at DESC);
CREATE INDEX idx_mood_records_mood_type ON mood_records(mood_type);
```

理由：
- 列表页按时间倒序 → recorded_at DESC 索引
- 统计页按情绪筛选 → mood_type 索引
- 数据量极小（个人记录），索引更多是习惯而非性能需求

### 5.3 数据库版本迁移

```dart
// database_helper.dart 示例
static const _currentVersion = 1;

static Future<Database> init() async {
  return openDatabase(
    path,
    version: _currentVersion,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE mood_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mood_type TEXT NOT NULL,
          intensity INTEGER NOT NULL CHECK(intensity BETWEEN 1 AND 5),
          note TEXT,
          recorded_at TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
      ''');
      await db.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_mood_records_recorded_at ON mood_records(recorded_at DESC)'
      );
      await db.execute(
        'CREATE INDEX idx_mood_records_mood_type ON mood_records(mood_type)'
      );
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // 未来版本迁移逻辑
    },
  );
}
```

## 6. 接口设计

### 6.1 内部接口（Repository 层）

MVP 阶段无网络 API，以下是应用内部 Repository 接口定义：

**MoodRepository**

| 方法 | 签名 | 说明 |
|------|------|------|
| 创建记录 | Future\<MoodRecord\> create(MoodRecord record) | 保存情绪记录 |
| 更新记录 | Future\<MoodRecord\> update(MoodRecord record) | 编辑已有记录 |
| 删除记录 | Future\<void\> delete(int id) | 删除单条记录 |
| 清空所有 | Future\<void\> deleteAll() | 清空全部记录 |
| 查询列表 | Future\<List\<MoodRecord\>\> getList({int page, int pageSize, DateTimeRange? range}) | 分页查询，按时间倒序 |
| 统计摘要 | Future\<StatSummary\> getSummary({DateTimeRange? range}) | 平均强度、最频繁情绪、记录总数、记录天数 |
| 情绪分布 | Future\<Map\<MoodType, int\>\> getDistribution({DateTimeRange? range}) | 各情绪计数 |
| 强度趋势 | Future\<List\<TimeSeriesPoint\>\> getIntensityTrend({DateTimeRange? range}) | 按天聚合平均强度 |

**SettingsRepository**

| 方法 | 签名 | 说明 |
|------|------|------|
| 获取主题 | ThemeMode getThemeMode() | 获取当前主题设置 |
| 设置主题 | Future\<void\> setThemeMode(ThemeMode mode) | 切换主题 |
| 引导完成 | bool isOnboardingComplete() | 是否完成引导 |
| 标记引导完成 | Future\<void\> markOnboardingComplete() | 标记已完成 |
| 滑动引导 | bool isSwipeGuided() | 是否完成滑动引导 |
| 标记滑动引导 | Future\<void\> markSwipeGuided() | 标记已完成 |

**ExportService**

| 方法 | 签名 | 说明 |
|------|------|------|
| 导出 CSV | Future\<File\> exportCsv() | 生成 CSV 文件 |
| 分享文件 | Future\<void\> shareFile(File file) | 调用系统分享 |

### 6.2 数据模型

```dart
/// 情绪类型枚举
enum MoodType {
  happy('happy', '开心', '😊', 0.8),    // 效价分（积极→消极）
  calm('calm', '平静', '😌', 0.6),
  sad('sad', '难过', '😢', 0.3),
  anxious('anxious', '焦虑', '😰', 0.2),
  angry('angry', '生气', '😠', 0.1);

  final String key;
  final String label;
  final String emoji;
  final double valence; // 效价分，用于排列顺序
}

/// 情绪记录实体
class MoodRecord {
  final int? id;
  final MoodType moodType;
  final int intensity; // 1-5
  final String? note;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// 统计摘要
class StatSummary {
  final double averageIntensity;
  final MoodType mostFrequentMood;
  final int totalRecords;
  final int totalDays;
}
```

## 7. 关键架构决策（ADR）

### ADR-001：状态管理选择 Riverpod

背景： Flutter 状态管理方案众多（Provider/Riverpod/Bloc/GetX）。
决策： 选择 Riverpod 2.x。

理由：
- 编译时安全（相比 Provider 运行时才发现错误）
- 依赖注入内建，无需额外库
- 异步状态管理（AsyncValue）天然支持加载/错误/数据三态
- 社区趋势明确，Flutter 官方推荐

代价： 学习曲线略高于 Provider，但对于本项目复杂度完全可控。

### ADR-002：数据层采用 Repository 模式

背景： MVP 所有数据来自本地 SQLite，但 v3.0 可能引入云端同步。
决策： 采用 Repository 模式抽象数据源。

理由：
- UI 层不直接依赖 SQLite，未来替换/增加数据源无需改 UI
- Repository 内封装业务逻辑（统计计算、数据验证）
- DAO 层专注 SQL 操作，职责清晰

代价： 多一层抽象，代码量略增。但考虑到未来 v3.0 云端同步需求，这是值得的前期投入。

### ADR-003：粒子动画降级策略

背景： PRD 要求保存时播放粒子动画，低端机需自动降级。
决策： 首帧渲染时间检测 + 分级降级。

```
// 策略：
// Tier 1（高端）：完整粒子扩散动画（Canvas 自绘，多粒子）
// Tier 2（中端）：简单缩放+淡出动画
// 检测方式：首帧渲染 > 16ms → 降级到 Tier 2
// 降级结果持久化到 SharedPreferences，不重复检测
```

理由： 避免低端机卡顿影响用户体验，同时保留高端机的情感化体验。

### ADR-004：时间存储使用 ISO 8601 文本

背景： SQLite 没有原生日期类型。
决策： 使用 ISO 8601 字符串（yyyy-MM-ddTHH:mm:ss）存储时间。

理由：
- 可读性强，调试方便
- SQLite 内置 datetime() 函数可直接操作
- 避免时间戳整数的人肉转换

代价： 查询时需字符串比较，但数据量极小无性能影响。

## 8. 可靠性与失败模式

| 失败场景 | 影响 | 缓解措施 |
|----------|------|----------|
| SQLite 写入失败 | 记录丢失 | try-catch 包裹，失败时 Toast 提示，不重置表单 |
| 数据库损坏 | 所有数据丢失 | MVP 阶段接受；v2.0 增加自动备份 |
| CSV 导出失败 | 用户无法导出 | 错误 Toast + 重试提示 |
| 误删记录 | 单条数据丢失 | 确认弹窗防护；v2.0 可考虑软删除/回收站 |
| 误清空数据 | 全部数据丢失 | 高门槛确认（输入"清空"），不可撤销 |
| 主题切换闪烁 | 体验问题 | 300ms 过渡动画平滑切换 |

## 9. 性能目标

| 指标 | 目标 | 实现要点 |
|------|------|----------|
| 冷启动 | < 2s | SQLite 异步初始化、懒加载统计页数据 |
| 保存记录 | < 500ms | 本地写入无网络延迟；UI 先重置再异步写库 |
| 图表加载 | < 1s | 限制数据范围（7/30天）、异步计算 |
| 粒子动画 | < 200ms 首帧 | 自定义 Canvas 绘制、低端机降级 |
| 列表滑动 | 60fps | RecyclerView 等价（Flutter ListView.builder 懒加载） |
| 内存占用 | < 100MB | 图片资源压缩、图表按需加载 |

## 10. 开发步骤

### 阶段 0：项目搭建（1天）
- Flutter 项目初始化（flutter create）
- 目录结构搭建（按 2.2 模块划分）
- 引入依赖：sqflite、riverpod、fl_chart、go_router、shared_preferences、csv、share_plus
- 配置主题系统（浅色/深色色值 Token）
- 配置路由（4个 Tab 页 + Onboarding）
- SQLite 初始化 + 建表

### 阶段 1：核心数据层（2-3天）
- 定义数据模型（MoodType 枚举、MoodRecord 实体）
- 实现 MoodDao（CRUD + 统计查询）
- 实现 MoodRepository
- 实现 SettingsRepository
- 单元测试覆盖核心查询

### 阶段 2：首页 — 情绪记录（3-4天）
- 情绪选择组件（EmotionButton + 动画）
- 强度滑块组件（IntensitySlider）
- 备注输入（键盘适配、sticky bottom）
- 时间修改（DateTime Picker）
- 粒子保存动画（含降级策略）
- 连接 Repository 完成保存

### 阶段 3：记录列表（2-3天）
- 列表页（日期分组 + 分页加载）
- 左滑删除 / 右滑编辑（手势优先级处理）
- ⋯ 更多菜单
- 首次滑动引导动画
- 编辑页（复用 US-1 表单）
- 下拉刷新

### 阶段 4：统计趋势（2-3天）
- 统计摘要卡片（2×2 网格）
- 情绪分布环形图（fl_chart）
- 强度趋势折线图（fl_chart）
- 时间范围切换（7天/30天/全部）
- 数据不足折叠提示

### 阶段 5：设置与全局（2天）
- "我的"页面布局
- 深色模式切换（含跟随系统）
- CSV 数据导出
- 清空数据（高门槛确认）
- Tab Bar 壳页面

### 阶段 6：首次引导（1天）
- 3 页引导卡片
- 跳过选项
- 首次判断逻辑
- "我的"页重播入口

### 阶段 7：打磨与测试（3-4天）
- 深色模式全面适配
- 动效微调
- 边界状态处理（空状态、错误态）
- 响应式适配（小屏/大屏）
- 无障碍基础支持
- 真机测试（iOS + Android）
- 性能优化

**总计：约 16-21 天（3-4 周）**

## 11. v2.0 / v3.0 演进预留

| 版本 | 功能 | 架构影响 |
|------|------|----------|
| v2.0 | 桌面小组件 | 新增 Widget Extension Target；共享 SQLite 数据 |
| v2.0 | 标签系统 | mood_records 增加关联表 tags / record_tags |
| v2.0 | 高级筛选 | Repository 层增加组合查询 |
| v2.0 | 日历热力图 | 新增 Calendar 页面模块 |
| v3.0 | 云端同步 | 引入后端 API + 本地/远程数据合并策略（最大架构变更） |

v3.0 云端同步的关键挑战：数据冲突解决策略（Last-Write-Wins vs 用户选择）。建议 MVP 阶段为每条记录生成 UUID，为未来同步预留。

## 12. 风险与约束

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| Flutter 热重载掩盖真机性能问题 | Medium | Medium | Release 模式真机测试 |
| SQLite 数据迁移兼容性 | Low | High | 严格版本管理 + 迁移测试 |
| 深色/浅色双主题维护成本 | Medium | Medium | 设计 Token 体系 + 主题生成器 |
| 粒子动画低端机卡顿 | Medium | Medium | 帧率检测自动降级 |
| 个人开发精力不足 | High | High | 严格 MVP 范围控制，v2.0 功能坚决不做 |

---

文档版本：v1.0 | 基于 PRD v2.5 + UI/UX v1.0 | 架构师：Astra 🏛️
下一步：技术选型确认 → 搭建项目骨架 → 开始阶段 1
