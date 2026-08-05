import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'
import { App as AntdApp, ConfigProvider } from 'antd'
import zhCN from 'antd/locale/zh_CN'

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
    return importPage()
  },

  // 用 antd ConfigProvider 注入设计系统主题（主色黛青 #1B6E78、圆角 6、中文语言包）
  // 用 antd <App> 包裹，启用 message/notification/modal 静态方法并继承主题上下文
  setup({ el, App: InertiaApp, props }) {
    createRoot(el).render(
      <ConfigProvider
        locale={zhCN}
        theme={{ cssVar: true, token: { colorPrimary: '#1B6E78', borderRadius: 6 } }}
      >
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
    visitOptions: () => {
      return { queryStringArrayFormat: 'brackets' }
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
