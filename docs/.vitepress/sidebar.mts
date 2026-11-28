import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

export interface SidebarItem {
  text: string
  link?: string
  items?: SidebarItem[]
}

const here = path.dirname(fileURLToPath(import.meta.url))
const docsRoot = path.resolve(here, '..')

/** 读取 frontmatter 的 title / order，没有就退回到第一个一级标题 */
function readMeta(file: string): { title?: string; order?: number } {
  let raw = ''
  try {
    raw = fs.readFileSync(file, 'utf-8')
  } catch {
    return {}
  }
  const fm = raw.match(/^---\r?\n([\s\S]*?)\r?\n---/)
  let title: string | undefined
  let order: number | undefined
  if (fm) {
    const block = fm[1]!
    const mTitle = block.match(/^title:\s*["']?(.+?)["']?\s*$/m)
    if (mTitle) title = mTitle[1]
    const mOrder = block.match(/^order:\s*(\d+)\s*$/m)
    if (mOrder) order = Number(mOrder[1])
  }
  if (!title) {
    const mH1 = raw.match(/^#\s+(.+?)\s*$/m)
    if (mH1) title = mH1[1]
  }
  if (title) title = title.replace(/[*`_]/g, '').trim()
  return { title, order }
}

/**
 * 扫描某个栏目目录，生成侧边栏条目：
 * 目录（index.md）固定在最前，其余按 frontmatter order（没有则按文件名自然排序）。
 * 新增章节只要往对应目录扔一个 .md 文件即可，不用再改 config。
 */
export function sectionSidebar(section: string): SidebarItem[] {
  const dir = path.join(docsRoot, section)
  const base = `/${section}/`
  const items: SidebarItem[] = [{ text: '目录', link: base }]
  if (!fs.existsSync(dir)) return items

  const names = fs
    .readdirSync(dir, { withFileTypes: true })
    .filter(
      (entry) =>
        entry.isFile() &&
        entry.name.endsWith('.md') &&
        entry.name !== 'index.md' &&
        !entry.name.startsWith('_') &&
        !entry.name.startsWith('.'),
    )
    .map((entry) => entry.name)

  const chapters = names
    .map((name) => {
      const meta = readMeta(path.join(dir, name))
      return {
        name,
        text: meta.title ?? name.replace(/\.md$/, ''),
        order: meta.order ?? Number.POSITIVE_INFINITY,
      }
    })
    .sort(
      (a, b) =>
        a.order - b.order || a.name.localeCompare(b.name, 'zh-CN', { numeric: true }),
    )

  for (const chapter of chapters) {
    items.push({
      text: chapter.text,
      link: `${base}${chapter.name.replace(/\.md$/, '.html')}`,
    })
  }
  return items
}
