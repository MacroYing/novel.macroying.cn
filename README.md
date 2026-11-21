# novel.macroying.cn

MacroYing 的文学小站源码，基于 **VuePress 2**。

线上地址：<https://novel.macroying.cn>

## 技术栈

- VuePress 2（vite bundler）+ `@vuepress/theme-default`
- 中文长文排版、深色模式、本地搜索、章节翻页

## 本地开发

```bash
npm install        # 首次安装依赖
npm run dev        # 开发模式 http://127.0.0.1:8080
npm run build      # 生产构建，产物在 docs/.vuepress/dist
```

需要后台常驻时：

```bash
npm run serve      # 后台启动，关掉终端也不停（日志 /tmp/vuepress-dev.log）
npm run stop       # 停止后台进程
```

## 部署

推送到 `main` 分支即自动部署到热铁盒网页托管：

- `.github/workflows/deploy.yml`：调用 `rthsoftware/host-auto-deploy` 动作
- `rth-host.json`：站点域名、构建命令（`build`）与输出目录（`docs/.vuepress/dist`）
- 仓库需配置 Secret `RTH_API_KEY`（热铁盒控制台 → API 密钥）

本地手动部署（需先安装 Deno，并设置环境变量 `RTH_API_KEY`）：

```bash
npm run deploy
```

## 目录结构

```
docs/                    站点内容
├── README.md            首页（hero、作品卡片）
├── about.md             关于
├── copyright.md         版权说明
├── works/               作品页
└── .vuepress/
    ├── config.ts        站点标题、导航、主题配置
    ├── public/          静态资源（头像、favicon、字体）
    └── styles/          自定义样式
tools/build-fonts.sh     字体子集化工具
serve.sh / stop.sh       本地后台启停脚本
```

## 写作

在 `docs/works/` 下新建 Markdown 文件即可，导航与侧边栏配置见 `docs/.vuepress/config.ts`。
