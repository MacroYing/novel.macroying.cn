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


## 反向同步 / 备份

热铁盒官方只提供「推送到 Git → 自动部署」这一个方向，没有反向同步功能，
其 WAF 也会拦截云服务器 / 代理 IP，所以不适合在 GitHub Actions 里跑。

需要把线上内容拉回来对照或备份时，在本地执行：

```bash
python3 tools/rth-pull.py                 # 抓取到 retiehe-mirror/（默认域名 novel.macroying.cn）
python3 tools/rth-pull.py --site xxx.rth1.xyz --out /tmp/mirror
```

脚本按站点公开 URL 抓取页面与资源，生成 `retiehe-mirror/manifest.json` 记录每个文件的 SHA-256；
再次运行会按上次清单列出「新增 / 修改 / 删除」，也就是线上相对上次快照改了什么。
镜像目录默认不纳入 Git（`.gitignore` 里已忽略）。

注意：线上是 `docs/.vuepress/dist` 的构建产物，不是源码。反向拉回来的文件用于**对照与备份**，
要长期保留改动仍应回到 Markdown 源码编辑、再 push 部署，否则下次部署会覆盖线上。

## 协议

- **站点本身**（页面、样式与站点代码）：[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.zh-hans)，可署名非商业地分享，不得商用
- **文学文本**（`docs/` 下的文章与作品）：著作权归作者所有，未开源，转载与改编需先获许可

文字内容与站点页面分开授权，详见 [版权说明](docs/copyright.md) 与 [LICENSE](LICENSE)。
