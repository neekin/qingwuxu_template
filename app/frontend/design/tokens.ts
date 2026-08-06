/**
 * 青乌序（QingWuXu）设计令牌 —— 单一数据源（Single Source of Truth）
 * --------------------------------------------------------------------------
 * 这是整套设计系统的「唯一真相来源」。
 *  - 前台（Rails + Hotwire + Tailwind）通过 tailwind.config.js 引入本文件；
 *  - 后台（Rails + Inertia + React + antd）通过 antdTheme.ts 引入本文件；
 *  - 运行时换肤 / 暗色模式通过 qingwuxu.css 中的 CSS 变量镜像本文件。
 *
 * 命名约定：
 *  青 = 主色（黛青 / 神鸟意象）
 *  缃 = 辅助色（赭石暖调，青花瓷互补色）
 *  墨 = 中性灰阶（偏冷，呼应水墨）
 *
 * 修改令牌请只改这里，禁止在 Tailwind 配置或 antd 主题中硬编码颜色。
 */

export const color = {
  /** 主色：黛青（青乌神鸟意象），用于主按钮、链接、品牌色 */
  primary: {
    50: '#EAF4F4',
    100: '#D2E8E9',
    200: '#A5D1D4',
    300: '#73B7BC',
    400: '#459BA2',
    500: '#2A828C',
    600: '#1B6E78', // 品牌主色（solid 按钮 / 链接 / antd colorPrimary）
    700: '#155962',
    800: '#114750',
    900: '#0B333C',
  },
  /** 辅助色：赭石（东方暖调，用于点缀、图表第二序列、空状态插画） */
  auxiliary: {
    50: '#FBF4E9',
    100: '#F5E6CE',
    200: '#EACF9C',
    300: '#DDB368',
    400: '#CF9A45',
    500: '#BF8430', // 赭石（辅助强调）
    600: '#A06D27',
    700: '#7E5520',
    800: '#5C3F1A',
    900: '#3D2A12',
  },
  /** 语义色：成功 */
  success: {
    50: '#E7F6EF',
    100: '#C2E9D6',
    500: '#1F9D6B', // 主用
    600: '#188554',
    700: '#126B43',
  },
  /** 语义色：警告 */
  warning: {
    50: '#FCF2E0',
    100: '#F7DFB0',
    500: '#E0922A', // 主用
    600: '#C77A1C',
    700: '#A36215',
  },
  /** 语义色：错误 */
  error: {
    50: '#FBEAE8',
    100: '#F4C7C2',
    500: '#D43829', // 朱砂（主用）
    600: '#B62E21',
    700: '#96251A',
  },
  /** 语义色：信息（复用主色青系） */
  info: {
    500: '#2A828C',
    600: '#1B6E78',
    700: '#155962',
  },
  /**
   * 中性灰阶：墨（偏冷，呼应水墨）
   * 同时承担 surface / border / text 语义，详见 semantic。
   */
  ink: {
    0: '#FFFFFF',
    50: '#F7F9F9',
    100: '#EEF2F2',
    200: '#DCE4E4',
    300: '#C3CFCF',
    400: '#9AABAB',
    500: '#6E7E7E',
    600: '#51605F',
    700: '#3A4645',
    800: '#283130',
    900: '#18211F',
    950: '#0E1413',
  },
  /** 语义化表面 / 边框 / 文本（开发直接引用这些，不要裸用 ink 数值） */
  semantic: {
    'bg-base': '#F7F9F9', // 应用底色
    'bg-surface': '#FFFFFF', // 卡片 / 浮层
    'bg-subtle': '#EEF2F2', // 次级区域 / 表头
    'bg-muted': '#DCE4E4', // 禁用 / 占位
    'border-subtle': '#DCE4E4',
    'border-default': '#C3CFCF',
    'border-strong': '#9AABAB',
    'text-primary': '#283130', // 标题
    'text-regular': '#3A4645', // 正文
    'text-secondary': '#6E7E7E', // 辅助 / 说明
    'text-disabled': '#9AABAB',
    'text-on-primary': '#FFFFFF',
    'text-link': '#1B6E78',
  },
} as const;

/** 字体族（中英文 + 等宽） */
export const font = {
  /** UI / 正文（无衬线，工程清晰感） */
  sans:
    '-apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", "Noto Sans SC", "Helvetica Neue", Helvetica, Arial, sans-serif',
  /** 品牌 / 标题（衬线，东方书法秩序感，用于 Landing / Logo / 大标题） */
  serif: '"Noto Serif SC", "Source Han Serif SC", "Songti SC", "SimSun", serif',
  /** 代码 / 数据 */
  mono: '"JetBrains Mono", "Fira Code", "SFMono-Regular", Menlo, Consolas, "Liberation Mono", monospace',
} as const;

/**
 * 间距比例：4px 基数（与 Tailwind 默认一致）
 * 键名 1..24 直接映射到 Tailwind 的 spacing 刻度（space-1 = 4px）。
 */
export const space = {
  0: '0px',
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  8: '32px',
  10: '40px',
  12: '48px',
  16: '64px',
  20: '80px',
  24: '96px',
} as const;

/** 圆角：默认 6px，与 antd 默认 borderRadius 对齐，强化「秩序感」 */
export const radius = {
  xs: '2px',
  sm: '4px',
  md: '6px', // DEFAULT
  lg: '10px',
  xl: '14px',
  '2xl': '20px',
  full: '9999px',
} as const;

/** 阴影：水墨风，偏冷、柔和 */
export const shadow = {
  xs: '0 1px 2px rgba(14,20,19,0.06)',
  sm: '0 1px 3px rgba(14,20,19,0.08), 0 1px 2px rgba(14,20,19,0.04)',
  md: '0 4px 12px rgba(14,20,19,0.08)',
  lg: '0 8px 24px rgba(14,20,19,0.10)',
  xl: '0 16px 48px rgba(14,20,19,0.12)',
  focus: '0 0 0 3px rgba(27,110,120,0.18)', // 主色聚焦环
} as const;

/** 层级（z-index / elevation） */
export const z = {
  base: 0,
  dropdown: 1000,
  sticky: 1020,
  header: 1030,
  drawer: 1040,
  modal: 1050,
  popover: 1060,
  tooltip: 1070,
  toast: 1080,
  spin: 1090,
} as const;

/** 动效 */
export const motion = {
  ease: 'cubic-bezier(0.4, 0, 0.2, 1)',
  easeOut: 'cubic-bezier(0.16, 1, 0.3, 1)',
  fast: '120ms',
  base: '200ms',
  slow: '320ms',
} as const;

/** 组件尺寸（控件高度，前后台对齐） */
export const control = {
  height: '32px', // 默认
  heightLG: '40px',
  heightSM: '24px',
} as const;

export const tokens = { color, font, space, radius, shadow, z, motion, control } as const;
export default tokens;
