# macroLiterature（VuePress 2 空白模板）

一个站点名为 **macroLiterature** 的**内容留空**文学创作站脚手架：导航、章节翻页、搜索、深色模式和中文长文排版都已配好，
分类和内容全部留给你自己添加。

本地访问：<http://127.0.0.1:8080/>

当前状态：已用 `serve.sh` 后台常驻，退出终端后依然可访问。

## 快速开始

```bash
npm install     # 首次执行
npm run dev     # 前台开发模式（Ctrl+C 停止）
```

## 后台常驻

```bash
npm run serve   # 后台启动，关掉终端也不停，日志 /tmp/vuepress-dev.log
npm run stop    # 停止后台进程
```

## 站点结构

```
vuepress-docs/
├── package.json
├── serve.sh / stop.sh          后台启停脚本
└── docs/
    ├── .vuepress/
    │   ├── config.ts           站点名、导航、侧边栏、主题文案
    │   ├── styles/index.scss   主题色与中文阅读排版
    │   └── public/images/      avatar.jpg（圆形站标）、favicon.ico
    ├── README.md               首页（hero + 作品入口）
    ├── about.md                关于作者
    ├── copyright.md            版权与转载
    └── works/
        └── README.md           作品页（分类和条目由你自己建）
```

没有任何预设分类：长篇、短篇、诗、手记这些目录都已删除，`works/` 下只有一个空的作品页。

页面里的填写提示都写在 HTML 注释中（页面上看不见）。

## 开始写（分类由你定）

1. **建分类**：在 `docs/works/` 下新建目录（目录名就是访问路径），比如 `docs/works/novel/`，里面放一个 `README.md` 当分类首页。
2. **加条目**：目录里新建 `.md` 就是新页面。小说/散文章节开头写 `---
pageClass: chapter-page
---`（首行缩进 + 章末翻页），诗写 `pageClass: poem-page`（每行一段居中）。
3. **登记侧边栏**：在 `docs/.vuepress/config.ts` 的 `sidebar` 里按注释里的格式登记这个分类和它的条目。
4. **加导航/卡片**：顶栏要加分类入口就在 `navbar` 里加一项；首页和作品页的卡片、章节链接按注释模板补上。

## 改成你自己的站

改 `docs/.vuepress/config.ts` 的 `title`、`description`，以及首页 `docs/README.md` 的 `heroText`、`tagline`。

## 排版说明（已配好）

- 正文与界面中文用 **更纱黑体 SC**（Sarasa Gothic SC），字号 17px、行高 1.95、两端对齐、首行缩进 2 字。
- 标题里的西文用 **Montserrat**，中文自动回落到更纱黑体（只有一个字体族，不需要分别写）。
- 字体已做子集：更纱黑体常规 **1.2MB** / 粗体 **1.3MB**（原 ttf 各 25MB），Montserrat 各 19KB，全部离线、不走 CDN。
- 子集字符集 = 通用规范汉字表 8105 字 + GB2312 全集 + 站点用字，共 9,792 字符；生僻字回退系统字体。明细与重新生成方式见 `tools/fonts/README.md`（`bash tools/build-fonts.sh`，加 `--full` 可覆盖全部 CJK 基本区）。
- 阅读宽度 700px，章节标题居中，标题下有一枚朱砂色小饰。
- 正文页章末自动生成「上一章 / 下一章」（顺序取自侧边栏）；非正文页（首页/作品/关于）不显示翻页。
- 诗页（`pageClass: poem-page`）每行一段、居中；散文/小说页（`pageClass: chapter-page`）首行缩进。
- 亮色/暗色两套配色，主题色是朱砂红 `--vp-c-accent`，改 `styles/index.scss` 即可换。

## 命令

| 命令 | 作用 |
| --- | --- |
| `npm run dev` | 前台开发，热更新，127.0.0.1:8080 |
| `npm run serve` | 后台常驻启动 |
| `npm run stop` | 停止后台进程 |
| `npm run build` | 构建静态站点到 `docs/.vuepress/dist/` |
| `npm run clean` | 清理缓存与临时文件 |

## 版本

`vuepress` / `@vuepress/bundler-vite` 为 `2.0.0-rc.32`，主题与插件为 `2.0.0-rc.138`
（VuePress 2 核心包与主题/插件包分别独立发版，版本号不一样是正常的）。
构建额外需要 `sass`（主题的 scss 样式要用）。
