import '@testing-library/jest-dom/vitest'

// ---- jsdom polyfills：护住 antd / pro-components 在测试环境渲染 ----
// antd 响应式（Grid / PageContainer）依赖 matchMedia；jsdom 不实现，需补。
if (typeof window !== 'undefined' && !window.matchMedia) {
  window.matchMedia = ((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {},
    removeListener: () => {},
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => false,
  })) as unknown as typeof window.matchMedia
}

// antd 某些组件（表格/栅格测量）依赖 ResizeObserver；jsdom 不实现，需补。
if (typeof window !== 'undefined' && !('ResizeObserver' in window)) {
  class ResizeObserverStub {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
  window.ResizeObserver = ResizeObserverStub as unknown as typeof window.ResizeObserver
}

// 路由/锚点跳转在测试里无需真实滚动。
if (typeof window !== 'undefined' && !window.scrollTo) {
  window.scrollTo = () => {}
}
