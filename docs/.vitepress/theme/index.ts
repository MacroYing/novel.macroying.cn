import DefaultTheme from 'vitepress/theme'
import Layout from './Layout.vue'
import MarkdownEditor from './components/MarkdownEditor.vue'
import './custom.css'

export default {
  ...DefaultTheme,
  Layout,
  enhanceApp({ app, router, siteData }: any) {
    // 写作台组件：只在 /editor 页使用，客户端渲染
    app.component('MarkdownEditor', MarkdownEditor)
    DefaultTheme.enhanceApp?.({ app, router, siteData })
  },
}
