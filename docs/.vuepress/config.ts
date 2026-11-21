import { defineUserConfig } from 'vuepress'
import { viteBundler } from '@vuepress/bundler-vite'
import { defaultTheme } from '@vuepress/theme-default'
import { searchPlugin } from '@vuepress/plugin-search'

export default defineUserConfig({
  lang: 'zh-CN',

  // ===== 改成你自己的：站点名与描述 =====
  title: 'macroLiterature',
  description: 'MacroYing 的文学小站 —— 只送大脑。',

  head: [
    ['link', { rel: 'icon', href: '/images/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#9c3a35' }],
    ['meta', { name: 'author', content: 'MacroYing' }],
  ],

  bundler: viteBundler({
    viteOptions: {
      server: {
        // 手机上访问时避免 watch 耗尽 inotify
        watch: {
          usePolling: true,
          interval: 800,
          // 构建产物目录不参与监听，免得 npm run build 时页面反复刷新
          ignored: ['**/node_modules/**', '**/.vuepress/dist/**'],
        },
      },
    },
  }),

  theme: defaultTheme({
    logo: '/images/avatar.jpg',
    logoDark: '/images/avatar.jpg',
    editLink: false,
    lastUpdated: false,
    smoothScroll: true,
    colorMode: 'auto',
    colorModeSwitch: true,

    // 主题自带的界面文案（已中文化）
    locales: {
      '/': {
        selectLanguageName: '简体中文',
        selectLanguageText: '选择语言',
        selectLanguageAriaLabel: '选择语言',
        editLinkText: '编辑此页',
        lastUpdatedText: '上次更新',
        contributorsText: '作者',
        prev: '上 一 章',
        next: '下 一 章',
        pageNavbarLabel: '章节导航',
        notFound: ['这一页还空着', '也许它还没有被写出来'],
        backToHome: '回到首页',
        openInNewWindow: '在新窗口打开',
        toggleColorMode: '切换深色',
        toggleSidebar: '目录',
      },
    },

    navbar: [
      { text: '首页', link: '/' },
      { text: '作品', link: '/works/' },
      { text: '关于', link: '/about.md' },
      { text: '版权', link: '/copyright.md' },
    ],

    sidebar: {
      // 默认只保留站点基础导航。
      // 加了自己的分类后，按这个格式登记（键是路径前缀，children 里放条目路径）：
      // '/works/你的分类/': [
      //   { text: '分类名', children: ['/works/你的分类/README.md', '/works/你的分类/第一章.md'] },
      // ],
      '/': [
        {
          text: '站点',
          children: [
            { text: '首页', link: '/README.md' },
            { text: '作品', link: '/works/README.md' },
          ],
        },
        {
          text: '关于',
          children: [
            { text: '关于作者', link: '/about.md' },
            { text: '版权与转载', link: '/copyright.md' },
          ],
        },
      ],
    },
    sidebarDepth: 0,
  }),

  plugins: [
    searchPlugin({
      locales: {
        '/': { placeholder: '搜索作品、章节或诗句' },
      },
      hotKeys: ['s', '/', { key: 'k', ctrl: true }, { key: 'k', meta: true }],
      maxSuggestions: 10,
    }),
  ],
})
