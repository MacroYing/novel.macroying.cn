import { defineConfig } from 'vitepress'
import { sectionSidebar } from './sidebar.mts'

export default defineConfig({
  lang: 'zh-CN',
  title: 'macroSpace',
  description: 'MacroYing 的文学小站 —— 只送大脑。',

  head: [
    ['link', { rel: 'icon', href: '/images/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#18794e' }],
    ['meta', { name: 'author', content: 'MacroYing' }],
  ],

  // 手机上 inotify 有限，用轮询监听，避免改文件时热更新失效
  vite: {
    server: {
      watch: {
        usePolling: true,
        interval: 800,
      },
    },
  },

  themeConfig: {
    logo: '/images/avatar.jpg',
    siteTitle: 'macroSpace',

    nav: [
      { text: '首页', link: '/' },
      { text: '无界有边', link: '/wujieyoubian/' },
      { text: '设定集', link: '/settings/' },
      { text: '短篇', link: '/stories/' },
      { text: '关于', link: '/about.html' },
    ],

    // 三个栏目自动扫描目录生成侧边栏：新建 .md 即入目录，
    // 标题取 frontmatter title，没有则取第一个一级标题；
    // 顺序可用 frontmatter order 指定，缺省按文件名自然排序。
    sidebar: {
      '/wujieyoubian/': [{ text: '无界有边', items: sectionSidebar('wujieyoubian') }],
      '/settings/': [{ text: '设定集', items: sectionSidebar('settings') }],
      '/stories/': [{ text: '短篇', items: sectionSidebar('stories') }],
      '/': [
        {
          text: '站点',
          items: [
            { text: '首页', link: '/' },
            { text: '关于', link: '/about.html' },
            { text: '版权与转载', link: '/copyright.html' },
          ],
        },
      ],
    },

    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: '搜索',
            buttonAriaLabel: '搜索',
          },
          modal: {
            noResultsText: '没有找到相关内容',
            resetButtonTitle: '清除条件',
            footer: {
              selectText: '选择',
              navigateText: '切换',
              closeText: '关闭',
            },
          },
        },
      },
    },

    outline: {
      level: [2, 3],
      label: '本页目录',
    },

    docFooter: {
      prev: '上一章',
      next: '下一章',
    },

    darkModeSwitchLabel: '外观',
    sidebarMenuLabel: '目录',
    returnToTopLabel: '回到顶部',
    lastUpdated: false,
    editLink: {
      pattern: 'https://github.com/MacroYing/novel.macroying.cn/edit/main/docs/:path',
      text: '在 GitHub 编辑此页',
    },

    socialLinks: [{ icon: 'github', link: 'https://github.com/MacroYing' }],

    footer: {
      message: '只送大脑。',
      copyright: 'Copyright © 2026 MacroYing · 文字版权归作者所有',
    },
  },
})
