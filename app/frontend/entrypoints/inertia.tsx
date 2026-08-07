// antd v5/v6 用 CSS-in-JS：组件样式运行时自注入，但全局 reset（body margin、
// box-sizing、html/body 高度）不会自动注入。必须显式引入，否则裸页面带浏览器
// 默认边距、盒模型不一致。仅 admin 入口引入，不影响前台 importmap/Tailwind（R1/R6）。
import 'antd/dist/reset.css'

import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'
import { App as AntdApp, ConfigProvider } from 'antd'
import zhCN from 'antd/locale/zh_CN'
import { qingwuxuTheme } from '../design/antdTheme'

// 关键：Vite 不支持 `import(`../pages/${name}.tsx`)` 这种多层路径的变量动态导入
// （报错 "variables only represent file names one level deep"）。
// 用 import.meta.glob 静态收集所有页面模块，运行时按精确路径查表。
const pages = import.meta.glob('../pages/**/*.tsx')

void createInertiaApp({
  strictMode: true,

  // Ruby 端默认解析器吐出 "admin/inertia_example/index"，
  // 对应文件 app/frontend/pages/admin/inertia_example/index.tsx。
  // glob 返回的 key 形如 "../pages/admin/inertia_example/index.tsx"，精确命中。
  resolve: (name) => {
    const importPage = pages[`../pages/${name}.tsx`]
    if (!importPage) {
      throw new Error(`[inertia] 未找到页面组件: ${name}`)
    }
    return importPage() as any
  },

  // 用 antd ConfigProvider 注入青乌序设计系统主题（来自 design/antdTheme.ts，
  // 其唯一真相是 design/tokens.ts）。cssVar:true 暴露 --ant-* CSS 变量，便于换肤。
  // 用 antd <App> 包裹，启用 message/notification/modal 静态方法并继承主题上下文。
  setup({ el, App: InertiaApp, props }) {
    createRoot(el!).render(
      <ConfigProvider locale={zhCN} theme={{ ...qingwuxuTheme, cssVar: { key: 'ant' } }}>
        <AntdApp>
          <InertiaApp {...props} />
        </AntdApp>
      </ConfigProvider>,
    )
  },

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    // 集中注入 CSRF 头：Rails protect_from_forgery 校验 X-CSRF-Token（来自 meta
    // csrf-token），而 Inertia 走 axios/XHR 不会自动带。此处对每次 visit 动态读取
    // meta，避免每个页面手写 X-CSRF-Token（login/register 的 fetch 仍各自带）。
    visitOptions: () => {
      const csrf =
        (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement | null)
          ?.content || ''
      return {
        queryStringArrayFormat: 'brackets',
        headers: { 'X-CSRF-Token': csrf },
      }
    },
  },
}).catch((error) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById('app')) {
    throw error
  } else {
    console.error(
      'Missing root element.\n\n' +
      "If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n" +
      'Consider moving the inertia entrypoint tag to the Inertia-specific layout instead.',
    )
  }
})
