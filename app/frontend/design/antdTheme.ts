/**
 * 青乌序 —— 后台 antd 主题（Rails + Inertia + React）
 * --------------------------------------------------------------------------
 * 通过 antd v5 ConfigProvider 接入青乌序品牌令牌。
 * 所有颜色 / 圆角 / 字体均来自 tokens.ts，禁止在此硬编码。
 *
 * 使用方式（React 根组件）：
 *   import { ConfigProvider, App as AntApp } from 'antd';
 *   import { qingwuxuTheme } from './design/antdTheme';
 *   import zhCN from 'antd/locale/zh_CN';
 *
 *   <ConfigProvider theme={qingwuxuTheme} locale={zhCN}>
 *     <AntApp>{children}</AntApp>
 *   </ConfigProvider>
 */
import type { ThemeConfig } from 'antd';
import { tokens } from './tokens';

const { color, font, radius, control } = tokens;

export const qingwuxuTheme: ThemeConfig = {
  token: {
    // —— 品牌主色 / 语义色 ——
    colorPrimary: color.primary[600], // #1B6E78
    colorInfo: color.info[500],
    colorSuccess: color.success[500],
    colorWarning: color.warning[500],
    colorError: color.error[500],

    // —— 中性 / 文本 / 背景 ——
    colorTextBase: color.ink[800],
    colorBgBase: color.semantic['bg-base'],
    colorText: color.semantic['text-regular'],
    colorTextSecondary: color.semantic['text-secondary'],
    colorTextDisabled: color.semantic['text-disabled'],
    colorBorder: color.semantic['border-default'],
    colorBorderSecondary: color.semantic['border-subtle'],
    colorLink: color.semantic['text-link'],

    // —— 形状 / 字体 / 字号 ——
    borderRadius: parseInt(radius.md, 10), // 6（与 Tailwind 默认对齐）
    fontFamily: font.sans,
    fontSize: 14,
    lineHeight: 1.5714, // ≈ 22px
    fontWeightStrong: 600,

    // —— 控件尺寸（前后台对齐）——
    controlHeight: parseInt(control.height, 10), // 32
    controlHeightLG: parseInt(control.heightLG, 10), // 40
    controlHeightSM: parseInt(control.heightSM, 10), // 24

    // —— 聚焦态 ——
    colorPrimaryBg: color.primary[50],
    colorPrimaryBgHover: color.primary[100],
  },
  components: {
    Button: {
      primaryShadow: 'none', // 东方克制，不滥用投影
      fontWeight: 500,
      borderRadius: parseInt(radius.md, 10),
    },
    Layout: {
      headerBg: color.semantic['bg-surface'],
      headerHeight: 56,
      siderBg: color.ink[900], // 深色侧栏，墨色
      bodyBg: color.semantic['bg-base'],
    },
    Menu: {
      // 深色侧栏（神鸟栖于墨夜）
      darkItemBg: 'transparent',
      darkSubMenuItemBg: 'transparent',
      darkItemSelectedBg: color.primary[600],
      darkItemSelectedColor: color.semantic['text-on-primary'],
      darkItemHoverBg: 'rgba(255,255,255,0.08)',
      darkItemHoverColor: color.ink[0],
      darkItemColor: color.ink[300],
      itemHeight: 44,
      iconSize: 16,
    },
    Table: {
      headerBg: color.semantic['bg-subtle'],
      headerColor: color.semantic['text-primary'],
      headerSplitColor: 'transparent',
      rowHoverBg: color.primary[50],
      borderColor: color.semantic['border-subtle'],
      borderRadiusLG: parseInt(radius.lg, 10), // 10
      cellPaddingBlock: 12,
      cellPaddingInline: 16,
    },
    Card: {
      borderRadiusLG: parseInt(radius.lg, 10), // 10
      headerFontSize: 16,
    },
    Input: {
      borderRadius: parseInt(radius.md, 10),
      hoverBorderColor: color.primary[400],
      activeBorderColor: color.primary[600],
      activeShadow: '0 0 0 3px rgba(27,110,120,0.18)',
    },
    Modal: {
      borderRadiusLG: parseInt(radius.lg, 10),
      headerBg: color.semantic['bg-surface'],
    },
    Tabs: {
      inkBarColor: color.primary[600],
      itemSelectedColor: color.primary[600],
      itemHoverColor: color.primary[600],
    },
    Tag: {
      borderRadiusSM: parseInt(radius.sm, 10),
    },
  },
};

export default qingwuxuTheme;
