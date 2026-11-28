---
title: 写作台
outline: false
sidebar: false
aside: false
prev: false
next: false
---

# 写作台

在这里写正文，右边实时预览。写完「下载 .md」或「复制 Markdown」，放进仓库对应目录即可。

<ClientOnly>
  <MarkdownEditor />
</ClientOnly>

## 放好之后

1. 把文件保存到 `docs/works/<分类>/<文件名>.md`
2. 到 `docs/.vitepress/config.mts` 的 `sidebar` 里登记这一章
3. 本地 `npm run dev` 预览，确认没问题再提交

草稿会自动存在这台设备的浏览器里，换设备或清缓存就没了，重要内容记得下载。
