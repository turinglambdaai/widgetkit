# widgetkit

为 Racket 精选的 GUI 控件集合。它把几乎每个 `racket/gui` 应用都要用、而核心工具库又没提供、得自己从头写的控件——工具提示、占位符文本、网格布局、日期输入、虚拟列表、状态栏、不确定进度、步进器——聚合到一个 `(require widgetkit)` 之下，配一本手册和每个控件一个可运行的示例。

![Racket](https://img.shields.io/badge/Racket-9F1D20?logo=racket&logoColor=white) [![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

[English](README.md) · **中文**

## 特性

- **一次 require，一本手册** —— 常用控件集中一处，不必在各个包之间翻找
- **克制而非冗余** —— 每个控件都补 core `racket/gui` 的真空白，不重复造已有的轮子
- **复用优先于重写** —— 有成熟包就直接依赖；只有没人做过时才新写
- **每个控件配一个可运行示例** —— 另加一个可点开巡览的综合画廊
- **全合约 API** —— 每个控件的方法与关键参数都经 `provide/contract` + `class/c` 运行时校验，误用即快速失败并指明责任方（同时给 AI 提供机器可读的 API）

## 运行环境

| 依赖 | 用途 / 版本 |
|------|------------|
| Racket | 8.0 及以上 |
| `gui-lib` | `racket/gui` 工具库（自动随包安装） |

## 快速上手

### 1. 克隆

```bash
git clone https://github.com/turinglambdaai/widgetkit.git
cd widgetkit
```

### 2. 安装

```bash
raco pkg install
```

### 3. 运行画廊

```bash
racket examples/showcase.rkt
```

### 4. 使用

```racket
#lang racket/base
(require racket/gui/base
         widgetkit)

(define f (new frame% [label "my app"] [width 400] [height 160]))
(new stepper% [parent f] [min-value 0] [max-value 20] [initial 5])
(new status-bar% [parent f] [show-progress #t] [initial-message "就绪。"])
(send f show #t)
```

## 收录的控件

### 补缺（新写，MIT）

| 控件 | 为什么 core `racket/gui` 不够 |
|------|-------------------------------|
| `status-bar%` | 有 `message%` 和 `gauge%`，但没有现成的"文字 + 进度"状态栏 |
| `spinner%` | 只有确定进度的 `gauge%`，没有"忙碌中、时长未知"的指示器 |
| `stepper%` | `slider%` 能选范围，但没有紧凑的 `[-] 值 [+]` 数字步进 |
| `disclosure%` | 没有可折叠/展开收起的容器（"高级选项…"那种） |
| `image-view%` | 有 `canvas%`，但没有现成控件直接显示一张图片（fit / 固定缩放） |
| `progress-dialog%` | 没有长任务用的模态"处理中… / 取消"对话框（core 只有 `gauge%`） |
| `notification-banner%` | 没有瞬时可关闭的通知条/toast（core 只有模态 `message-box`） |
| `log-view%` | 没有可滚动、只读、自动滚到底的日志/控制台；手搓 `editor-canvas%`+`text%` 卡在伸缩与自动滚动 |
| `split-view%` | 没有可拖拽分栏（Qt QSplitter / GTK GtkPaned） |
| `toolbar%` | 没有标准动作工具栏（带分隔） |
| `search-field%` | 没有实时"搜索…"框（清除 + 边输边过滤） |
| `stack%` | 没有干净的页面切换；顺带解决 `tab-panel%` 无回调的坑 |

### 便捷包装（新写，MIT）

在聚合控件外面包一层，用统一的类隐藏其 API 陷阱。

| 控件 | 包装 | 作用 |
|------|------|------|
| `labeled-field%` | `cue-mixin` + `tooltip-mixin` | 隐藏 `cue-mixin` 的 2 参陷阱；一个类，`[cue]`/`[tooltip]` 一致 |
| `text-list%` | `canvas-list%` | 隐藏 3 参回调；接受简单的 `(λ (item) ...)` 动作 |

### 聚合（从成熟包 re-export）

| 控件 | 上游包 | 为什么 core `racket/gui` 不够 |
|------|--------|-------------------------------|
| `tooltip-mixin`、`cue-mixin`、`validate-mixin` | [gui-widget-mixins](https://github.com/alex-hhh/gui-widget-mixins)（Apache-2.0/MIT） | `text-field%` 没有工具提示、占位符、校验 |
| `table-panel%` | [table-panel](https://github.com/spdegabrielle/table-panel)（LGPL-2.1） | 只有水平/垂直面板，没有对齐的网格布局 |
| `canvas-list%` | [canvas-list](https://github.com/massung/racket-canvas-list)（MIT） | `list-box%` 无法虚拟化超大列表、无法自绘每项 |
| `date-text-field%` | [text-date](https://github.com/Kalimehtar/text-date)（MIT） | 没有日期输入控件 |

## 示例

每个控件在 [`examples/`](examples) 下都有一个最小、独立、可运行的示例，直接复制即可当起点：

| 示例 | 演示 |
|------|------|
| `showcase.rkt` | 核心控件画廊巡览 |
| `mini-task-list.rkt` | 组合多控件的真实小应用——可直接克隆 |
| `status-bar-demo.rkt` | `status-bar%` |
| `spinner-demo.rkt` | `spinner%` |
| `stepper-demo.rkt` | `stepper%` |
| `tooltip-cue-demo.rkt` | `cue-mixin` + `tooltip-mixin` |
| `table-panel-demo.rkt` | `table-panel%` |
| `canvas-list-demo.rkt` | `canvas-list%` |
| `date-input-demo.rkt` | `date-text-field%` |
| `labeled-field-demo.rkt` | `labeled-field%`（cue + tooltip 便捷） |
| `text-list-demo.rkt` | `text-list%`（简单动作列表） |
| `disclosure-demo.rkt` | `disclosure%`（可折叠分组） |
| `image-view-demo.rkt` | `image-view%`（显示图片） |
| `progress-dialog-demo.rkt` | `progress-dialog%`（模态进度 + 取消） |
| `notification-banner-demo.rkt` | `notification-banner%`（通知条 / toast） |
| `log-view-demo.rkt` | `log-view%`（滚动日志，刷写工具风格） |
| `split-view-demo.rkt` | `split-view%`（可拖拽分栏） |
| `toolbar-demo.rkt` | `toolbar%`（工具栏驱动日志） |
| `search-field-demo.rkt` | `search-field%`（列表实时过滤） |
| `stack-demo.rkt` | `stack%`（用 choice% 切换页面） |

```bash
racket examples/status-bar-demo.rkt   # 任选一个
```

## 推荐另装

较重的控件**刻意不作为硬依赖**，以保持 `(require widgetkit)` 轻量。按需安装：

| 控件 | 安装 |
|------|------|
| 交互式 OSM 地图 | `raco pkg install map-widget` |
| 可排序多列数据网格 | `raco pkg install qresults-list` |
| 电子表格编辑器 | `raco pkg install spreadsheet-editor` |
| 在窗口里嵌入 `plot` | `raco pkg install plot-container` |
| WebView（Chromium / 原生） | `raco pkg install racket-webview` |

树/大纲视图 Racket 自带：[`mrlib/hierlist`](https://docs.racket-lang.org/mrlib/hierlist.html)——无需安装。

## 开发

```bash
raco test test/run.rkt               # 逻辑测试（任意环境可跑，无需显示）
bash test/run-gui-behavior.sh        # 行为测试（需要显示；Linux 下用 Xvfb）
raco make main.rkt examples/*.rkt
raco scribble --dest doc widgetkit.scrbl # 构建手册到 doc/
```

欢迎贡献控件——见 [CONTRIBUTING.md](CONTRIBUTING.md)。门槛很简单：必须补 core `racket/gui` 的真空白、附带可运行示例、写进文档。

## 许可证

基于 [MIT 许可证](LICENSE) 发布。聚合的控件保留各自上游许可证（Apache-2.0/MIT、LGPL-2.1、MIT），详见各包。
