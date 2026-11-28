<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { onMounted, onUnmounted, ref } from 'vue'

const Layout = DefaultTheme.Layout

const showBackTop = ref(false)
const progress = ref(0)

// 环形进度条：半径 20 的圆周长（viewBox 44 × 44）
const RING_LENGTH = 2 * Math.PI * 20

let onScroll: (() => void) | undefined

onMounted(() => {
  const root = document.documentElement
  // 渐进式模糊：滚过前 140px 时，模糊从 0 涨到 16px，材质从透明到可见
  const RANGE = 140
  const MAX_BLUR = 16
  onScroll = () => {
    const y = Math.max(0, window.scrollY)
    const t = Math.min(1, y / RANGE)
    root.style.setProperty('--ms-nav-alpha', t.toFixed(3))
    root.style.setProperty('--ms-nav-blur', `${(t * MAX_BLUR).toFixed(1)}px`)
    showBackTop.value = y > 400

    const max = document.documentElement.scrollHeight - window.innerHeight
    progress.value = max > 0 ? Math.min(1, Math.max(0, y / max)) : 0
  }
  window.addEventListener('scroll', onScroll, { passive: true })
  window.addEventListener('resize', onScroll, { passive: true })
  onScroll()
})

onUnmounted(() => {
  if (!onScroll) return
  window.removeEventListener('scroll', onScroll)
  window.removeEventListener('resize', onScroll)
})

function scrollToTop() {
  window.scrollTo({ top: 0, left: 0, behavior: 'smooth' })
}
</script>

<template>
  <Layout>
    <template #layout-top>
      <div class="ms-nav-veil" aria-hidden="true">
        <div class="ms-nav-veil__blur" />
        <div class="ms-nav-veil__tint" />
      </div>
      <button
        type="button"
        class="ms-back-top"
        :class="{ visible: showBackTop }"
        aria-label="回到顶部"
        title="回到顶部"
        @click="scrollToTop"
      >
        <svg class="ms-back-top__ring" viewBox="0 0 44 44" aria-hidden="true">
          <circle class="ring-track" cx="22" cy="22" r="20" />
          <circle
            class="ring-progress"
            cx="22"
            cy="22"
            r="20"
            :stroke-dasharray="RING_LENGTH"
            :stroke-dashoffset="RING_LENGTH * (1 - progress)"
          />
        </svg>
        <svg class="ms-back-top__icon" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M7.41 15.41 12 10.83l4.59 4.58L18 14l-6-6-6 6z" fill="currentColor" />
        </svg>
      </button>
    </template>
  </Layout>
</template>
