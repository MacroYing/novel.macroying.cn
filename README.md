# novel.macroying.cn

MacroYing 的文学小站源码，基于 **VitePress 2**（默认主题 + 绿色配色）。

线上地址：<https://novel.macroying.cn>

## 技术栈

- VitePress 2.0（alpha）+ 默认主题，版式参考 officetool.plus
- 主题色为绿色（`#18794e → #30a46c`），深色模式自动适配
- 内置本地搜索、侧边栏目录、上下章翻页

## 本地开发

```bash
npm install        # 首次安装依赖
npm run dev        # 开发模式 http://127.0.0.1:8080
npm run build      # 生产构建，产物在 docs/.vitepress/dist
npm run preview    # 预览构建产物
```

需要后台常驻时：

```bash
npm run serve      # 后台启动，关掉终端也不停（日志 /tmp/vuepress-dev.log）
npm run stop       # 停止后台进程
```

## 部署

推送到 `main` 分支即自动部署到热铁盒网页托管：

- `.github/workflows/deploy.yml`：调用 `rthsoftware/host-auto-deploy` 动作
- `rth-host.json`：站点域名、构建命令（`build`）与输出目录（`docs/.vitepress/dist`）
- 仓库需配置 Secret `RTH_API_KEY`（热铁盒控制台 → API 密钥）

本地手动部署（需先安装 Deno，并设置环境变量 `RTH_API_KEY`）：

```bash
npm run deploy
```

## 目录结构

```
docs/                    站点内容
├── index.md             首页（hero、特性卡片）
├── about.md             关于
├── copyright.md         版权说明
├── works/               作品页
├── public/              静态资源（头像、favicon、字体）
└── .vitepress/
    ├── config.mts       站点标题、导航、侧边栏、搜索
    └── theme/
        ├── index.ts     主题入口
        └── custom.css   绿色配色与阅读排版
tools/build-fonts.sh     字体子集化工具
serve.sh / stop.sh       本地后台启停脚本
```

## 写作

在 `docs/works/` 下新建 Markdown 文件即可：

- 小说 / 散文页在 frontmatter 里写 `pageClass: chapter-page`（首行缩进）
- 诗页写 `pageClass: poem-page`（逐行居中）
- 导航与侧边栏配置见 `docs/.vitepress/config.mts`

## 协议

- **站点本身**（页面、样式与站点代码）：[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.zh-hans)，可署名非商业地分享，不得商用
- **文学文本**（`docs/` 下的文章与作品）：著作权归作者所有，未开源，转载与改编需先获许可

文字内容与站点页面分开授权，详见 [版权说明](docs/copyright.md) 与 [LICENSE](LICENSE)。
