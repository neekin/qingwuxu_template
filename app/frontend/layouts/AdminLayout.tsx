import { useState, useEffect } from 'react'
import type { ReactNode } from 'react'
import { Layout, Menu, Avatar, Breadcrumb, Button } from 'antd'
import type { MenuProps } from 'antd'
import { usePage, Link } from '@inertiajs/react'
import { MenuFoldOutlined, MenuUnfoldOutlined } from '@ant-design/icons'
import { adminMenu, type AdminMenuItem } from '../config/adminMenu'

const { Sider, Header, Content } = Layout

/** 从菜单树推导当前路径的面包屑链（含父级） */
function findChain(items: AdminMenuItem[], path: string, chain: AdminMenuItem[] = []): AdminMenuItem[] | null {
  for (const item of items) {
    if (item.path === path) return [...chain, item]
    if (item.children) {
      const found = findChain(item.children, path, [...chain, item])
      if (found) return found
    }
  }
  return null
}

/** 把菜单配置映射为 antd Menu items（叶子用 Inertia Link 导航，父级由 antd 自动展开） */
function toMenuItems(items: AdminMenuItem[]): MenuProps['items'] {
  return items.map((m) => ({
    key: m.path ?? m.key,
    icon: m.icon,
    label: m.children ? m.label : m.path ? <Link href={m.path}>{m.label}</Link> : m.label,
    children: m.children?.map((c) => ({
      key: c.path ?? c.key,
      icon: c.icon,
      label: <Link href={c.path}>{c.label}</Link>,
    })),
  }))
}

export default function AdminLayout({ children }: { children: ReactNode }) {
  const page = usePage()
  const currentPath = page.url.split('?')[0]
  const chain = findChain(adminMenu, currentPath) ?? []
  const selectedKey = chain.length ? (chain[chain.length - 1].path ?? '') : currentPath
  const activeParentKey = chain.length > 1 ? chain[chain.length - 2].key : ''
  const [collapsed, setCollapsed] = useState(false)
  // 受控 openKeys：初始展开当前页所在的父级菜单；
  // 此后手动展开/收起只更新 state，导航刷新不会被 URL 重算覆盖，从而「记住」用户的选择。
  const [openKeys, setOpenKeys] = useState<string[]>(() =>
    activeParentKey ? [activeParentKey] : [],
  )
  // 导航到新页面时，仅把「当前页的父级」合并进 openKeys，
  // 不覆盖用户手动展开的其他子菜单（已展开的保持展开，已收起的保持收起）。
  useEffect(() => {
    if (!activeParentKey) return
    setOpenKeys((prev) => (prev.includes(activeParentKey) ? prev : [...prev, activeParentKey]))
  }, [activeParentKey])

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider theme="dark" collapsible collapsed={collapsed} trigger={null} width={220}>
        <div
          style={{
            height: 56,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#fff',
            fontWeight: 600,
            fontSize: collapsed ? 16 : 18,
            letterSpacing: 2,
            borderBottom: '1px solid rgba(255,255,255,0.08)',
          }}
        >
          {collapsed ? '青' : '青乌序'}
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[selectedKey]}
          openKeys={openKeys}
          onOpenChange={(keys) => setOpenKeys(keys)}
          items={toMenuItems(adminMenu)}
        />
      </Sider>
      <Layout>
        <Header
          style={{
            padding: '0 16px',
            background: '#fff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderBottom: '1px solid #f0f0f0',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <Button type="text" icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />} onClick={() => setCollapsed((v) => !v)} />
            <Breadcrumb items={chain.map((c) => ({ title: c.label }))} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <Button type="text">暗色</Button>
            <Avatar style={{ backgroundColor: '#1B6E78' }}>管</Avatar>
            <span>管理员</span>
          </div>
        </Header>
        <Content style={{ margin: 0, padding: 24, minHeight: 'calc(100vh - 56px)', background: '#F7F9F9' }}>
          {children}
        </Content>
      </Layout>
    </Layout>
  )
}
