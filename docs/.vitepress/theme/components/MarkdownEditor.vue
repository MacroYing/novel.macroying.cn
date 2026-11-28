<script setup lang="ts">
import { computed, nextTick, onMounted, ref, watch } from 'vue'

type Kind = 'normal' | 'chapter' | 'poem'

const STORAGE_KEY = 'macroSpace:draft:v1'

const title = ref('')
const dir = ref('novel')
const slug = ref('')
const kind = ref<Kind>('normal')
const body = ref('')

const html = ref('')
const savedAt = ref('')
const copied = ref(false)
const ta = ref<HTMLTextAreaElement | null>(null)

let md: any = null
let saveTimer: ReturnType<typeof setTimeout> | undefined

const pageClass = computed(() =>
  kind.value === 'chapter' ? 'chapter-page' : kind.value === 'poem' ? 'poem-page' : ''
)

const fileName = computed(() => {
  const base = slug.value.trim() || slugify(title.value) || 'untitled'
  return base.replace(/\.md$/i, '') + '.md'
})

const filePath = computed(() => `docs/works/${(dir.value || '分类').trim()}/${fileName.value}`)

const frontmatter = computed(() => {
  const lines = [`title: ${title.value.trim() || '无题'}`]
  if (pageClass.value) lines.push(`pageClass: ${pageClass.value}`)
  return `---\n${lines.join('\n')}\n---\n`
})

const output = computed(
  () => frontmatter.value + '\n' + (title.value.trim() ? `# ${title.value.trim()}\n\n` : '') + body.value
)

function slugify(s: string) {
  return s
    .trim()
    .toLowerCase()
    .replace(/[\s_]+/g, '-')
    .replace(/[^\w\u4e00-\u9fa5-]+/g, '')
    .replace(/^-+|-+$/g, '')
}

function render() {
  if (!md) return
  html.value = md.render(body.value || '')
}

function persist() {
  savedAt.value = new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  try {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        title: title.value,
        dir: dir.value,
        slug: slug.value,
        kind: kind.value,
        body: body.value,
      })
    )
  } catch {
    /* 隐私模式等写不进去就算了 */
  }
}

function scheduleSave() {
  clearTimeout(saveTimer)
  saveTimer = setTimeout(persist, 500)
}

function restore() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return
    const d = JSON.parse(raw)
    title.value = d.title || ''
    dir.value = d.dir || 'novel'
    slug.value = d.slug || ''
    kind.value = d.kind || 'normal'
    body.value = d.body || ''
    savedAt.value = '已恢复上次草稿'
  } catch {
    /* 忽略损坏的草稿 */
  }
}

function insert(before: string, after = '', placeholder = '文字') {
  const el = ta.value
  if (!el) return
  const start = el.selectionStart ?? body.value.length
  const end = el.selectionEnd ?? body.value.length
  const sel = body.value.slice(start, end) || placeholder
  body.value = body.value.slice(0, start) + before + sel + after + body.value.slice(end)
  nextTick(() => {
    el.focus()
    el.selectionStart = start + before.length
    el.selectionEnd = start + before.length + sel.length
  })
}

function insertLine(text: string) {
  const el = ta.value
  if (!el) return
  const start = el.selectionStart ?? body.value.length
  const lineStart = body.value.lastIndexOf('\n', Math.max(0, start - 1)) + 1
  body.value = body.value.slice(0, lineStart) + text + body.value.slice(lineStart)
  nextTick(() => {
    el.focus()
    el.selectionStart = el.selectionEnd = lineStart + text.length
  })
}

async function copy() {
  try {
    await navigator.clipboard.writeText(output.value)
    copied.value = true
    setTimeout(() => (copied.value = false), 1600)
  } catch {
    /* 剪贴板不可用时退回下载 */
    download()
  }
}

function download() {
  const blob = new Blob([output.value], { type: 'text/markdown;charset=utf-8' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob)
  a.download = fileName.value
  a.click()
  URL.revokeObjectURL(a.href)
}

function clearAll() {
  if (!confirm('清空标题和正文？草稿也会一起删掉。')) return
  title.value = ''
  slug.value = ''
  body.value = ''
  savedAt.value = ''
  try {
    localStorage.removeItem(STORAGE_KEY)
  } catch {
    /* 忽略 */
  }
}

watch(body, () => {
  render()
  scheduleSave()
})
watch([title, dir, slug, kind], scheduleSave)

onMounted(async () => {
  restore()
  try {
    const mod: any = await import('markdown-it')
    md = new (mod.default || mod)({ html: true, linkify: true, typographer: true })
    render()
  } catch {
    html.value = '<p>预览组件加载失败，但正文编辑不受影响。</p>'
  }
})
</script>

<template>
  <div class="ms-editor">
    <section class="pane">
      <div class="grid">
        <label class="field">
          <span>标题</span>
          <input v-model="title" type="text" placeholder="无题" />
        </label>
        <label class="field">
          <span>类型</span>
          <select v-model="kind">
            <option value="normal">普通页面</option>
            <option value="chapter">小说 / 散文（首行缩进）</option>
            <option value="poem">诗歌（逐行居中）</option>
          </select>
        </label>
      </div>

      <div class="grid">
        <label class="field">
          <span>分类目录</span>
          <input v-model="dir" type="text" placeholder="novel" />
        </label>
        <label class="field">
          <span>文件名</span>
          <input v-model="slug" type="text" placeholder="chapter-01" />
        </label>
      </div>

      <p class="hint">
        保存到 <code>{{ filePath }}</code>，再到
        <code>docs/.vitepress/config.mts</code> 的 sidebar 里登记这一章。
      </p>

      <div class="toolbar" role="toolbar" aria-label="格式">
        <button type="button" title="粗体" @click="insert('**', '**')">B</button>
        <button type="button" title="斜体" class="italic" @click="insert('*', '*')">I</button>
        <button type="button" title="行内代码" @click="insert('`', '`', '代码')">‹›</button>
        <button type="button" title="二级标题" @click="insertLine('## ')">H2</button>
        <button type="button" title="引用" @click="insertLine('> ')">❝</button>
        <button type="button" title="列表" @click="insertLine('- ')">≡</button>
        <button type="button" title="分隔线" @click="insertLine('\n---\n\n')">—</button>
        <button type="button" title="链接" @click="insert('[', '](https://)', '链接文字')">🔗</button>
        <button type="button" title="图片" @click="insert('![', '](/images/)', '图片描述')">🖼</button>
      </div>

      <textarea
        ref="ta"
        v-model="body"
        class="body-input"
        spellcheck="false"
        placeholder="在这里写正文，Markdown 语法，右边实时预览…"
      />

      <div class="actions">
        <button type="button" class="primary" @click="copy">
          {{ copied ? '已复制 ✓' : '复制 Markdown' }}
        </button>
        <button type="button" @click="download">下载 .md</button>
        <button type="button" class="ghost" @click="clearAll">清空</button>
        <span class="saved">{{ savedAt ? `草稿：${savedAt}` : '草稿自动保存在本机' }}</span>
      </div>
    </section>

    <section class="pane preview-pane">
      <div class="preview-head">
        <span class="label">实时预览</span>
        <code>{{ fileName }}</code>
      </div>
      <div v-if="!body.trim()" class="empty">左边写点什么，这里会实时出现。</div>
      <!-- eslint-disable-next-line vue/no-v-html -->
      <div v-else class="vp-doc preview" v-html="html" />
      <details class="fm">
        <summary>生成的 frontmatter</summary>
        <pre>{{ frontmatter }}</pre>
      </details>
    </section>
  </div>
</template>

<style scoped>
.ms-editor {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 1.5rem;
  margin: 1.5rem 0 3rem;
}

@media (max-width: 900px) {
  .ms-editor {
    grid-template-columns: minmax(0, 1fr);
  }
}

.pane {
  min-width: 0;
}

.preview-pane {
  position: sticky;
  top: calc(var(--vp-nav-height) + 1.5rem);
  align-self: start;
  max-height: calc(100vh - var(--vp-nav-height) - 3rem);
  overflow: auto;
  padding: 1rem 1.15rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
}

@media (max-width: 900px) {
  .preview-pane {
    position: static;
    max-height: none;
  }
}

.grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

@media (max-width: 560px) {
  .grid {
    grid-template-columns: 1fr;
  }
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  font-size: 0.82rem;
  color: var(--vp-c-text-2);
}

.field input,
.field select {
  padding: 0.45rem 0.6rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
  font-family: inherit;
}

.field input:focus,
.field select:focus,
.body-input:focus {
  outline: 2px solid var(--vp-c-brand-1);
  outline-offset: 1px;
  border-color: transparent;
}

.hint {
  margin: 0.2rem 0 0.9rem;
  font-size: 0.78rem;
  color: var(--vp-c-text-3);
  line-height: 1.7;
}

.hint code {
  font-size: 0.76rem;
  word-break: break-all;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  margin-bottom: 0.6rem;
}

.toolbar button {
  min-width: 2rem;
  height: 2rem;
  padding: 0 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  cursor: pointer;
  transition:
    border-color 0.2s,
    color 0.2s;
}

.toolbar button:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.toolbar .italic {
  font-style: italic;
}

.body-input {
  display: block;
  width: 100%;
  min-height: 380px;
  padding: 0.9rem 1rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 10px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-family: ui-monospace, 'SFMono-Regular', Consolas, monospace;
  font-size: 0.9rem;
  line-height: 1.8;
  resize: vertical;
}

.actions {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-top: 0.8rem;
}

.actions button {
  padding: 0.45rem 0.9rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  cursor: pointer;
  transition:
    background-color 0.2s,
    border-color 0.2s;
}

.actions button:hover {
  border-color: var(--vp-c-brand-1);
}

.actions button.primary {
  border-color: transparent;
  background: var(--vp-c-brand-3);
  color: #fff;
}

.actions button.primary:hover {
  background: var(--vp-c-brand-2);
}

.actions button.ghost {
  border-color: transparent;
  color: var(--vp-c-text-3);
}

.saved {
  margin-left: auto;
  font-size: 0.76rem;
  color: var(--vp-c-text-3);
}

.preview-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  margin-bottom: 0.6rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.preview-head .label {
  font-size: 0.78rem;
  letter-spacing: 0.08em;
  color: var(--vp-c-text-2);
}

.preview-head code {
  font-size: 0.74rem;
  color: var(--vp-c-text-3);
}

.preview {
  font-size: 0.95rem;
}

.empty {
  padding: 2.5rem 0;
  text-align: center;
  font-size: 0.85rem;
  color: var(--vp-c-text-3);
}

.fm {
  margin-top: 1rem;
  font-size: 0.76rem;
  color: var(--vp-c-text-3);
}

.fm summary {
  cursor: pointer;
}

.fm pre {
  margin: 0.5rem 0 0;
  padding: 0.6rem 0.75rem;
  border-radius: 8px;
  background: var(--vp-c-bg);
  overflow: auto;
}
</style>
