import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// 独立 vitest 配置：仅用 @vitejs/plugin-react 转 JSX，不挂 vite-plugin-ruby
// （避免 Rails 资产管线在测试环境初始化），测试经 Vite 的 esbuild 转译、不做类型检查。
export default defineConfig({
  plugins: [react()],
  esbuild: {
    jsx: 'automatic',
  },
  test: {
    environment: 'jsdom',
    globals: false,
    setupFiles: ['./app/frontend/tests/setup.ts'],
    include: ['app/frontend/**/*.test.{ts,tsx}'],
    css: false,
  },
})
