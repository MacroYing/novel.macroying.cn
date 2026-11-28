<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { onMounted, onUnmounted, ref } from 'vue'

const Layout = DefaultTheme.Layout

const showBackTop = ref(false)

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
        <svg class="ms-back-top__icon" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M7.41 15.41 12 10.83l4.59 4.58L18 14l-6-6-6 6z" fill="currentColor" />
        </svg>
      </button>
    </template>
  </Layout>
</template>
