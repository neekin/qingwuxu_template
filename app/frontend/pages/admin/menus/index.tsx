import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormSelect, ProFormDigit } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type Menu = {
  id: number
  name: string
  route: string
  permission_code: string
  menu_type: 'catalog' | 'menu' | 'button'
  status: 'visible' | 'hidden'
  icon: string
  component: string
  parent_id: number | null
  parent_name?: string
  sort: number
}

type Option = { id: number; name: string }

const typeMap: Record<Menu['menu_type'], { text: string; color: string }> = {
  catalog: { text: '目录', color: 'default' },
  menu: { text: '菜单', color: 'blue' },
  button: { text: '按钮', color: 'geekblue' },
}

const columns: ProColumns<Menu>[] = [
  { title: '菜单名称', dataIndex: 'name', search: true },
  {
    title: '类型',
    dataIndex: 'menu_type',
    render: (_, r) => <Tag color={typeMap[r.menu_type].color}>{typeMap[r.menu_type].text}</Tag>,
  },
  { title: '路由地址', dataIndex: 'route', ellipsis: true },
  { title: '权限字符', dataIndex: 'permission_code', ellipsis: true },
  {
    title: '上级',
    dataIndex: 'parent_name',
    search: false,
    render: (_, r) => (r.parent_name ? <Tag>{r.parent_name}</Tag> : <Tag>—</Tag>),
  },
  { title: '排序', dataIndex: 'sort' },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => (
      <Tag color={r.status === 'visible' ? 'success' : 'default'}>
        {r.status === 'visible' ? '显示' : '隐藏'}
      </Tag>
    ),
  },
]

const MenusPage = () => {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const menus = (props.menus as Menu[]) || []
  const allMenus = (props.all_menus as Option[]) || []

  // 编辑时回填父级（formItemsFor 机制注入 record）
  const formItemsFor = (_record?: Menu) => (
    <>
      <ProFormText name="name" label="菜单名称" rules={[{ required: true, message: '请输入菜单名称' }]} />
      <ProFormSelect
        name="menu_type"
        label="类型"
        initialValue="menu"
        options={[
          { value: 'catalog', label: '目录' },
          { value: 'menu', label: '菜单' },
          { value: 'button', label: '按钮' },
        ]}
      />
      <ProFormText name="route" label="路由地址" placeholder="如 /admin/users" />
      <ProFormText name="permission_code" label="权限字符" placeholder="如 system:menu:list" />
      <ProFormSelect
        name="parent_id"
        label="上级菜单"
        allowClear
        options={allMenus.map((m) => ({ value: m.id, label: m.name }))}
      />
      <ProFormText name="icon" label="图标" placeholder="如 MenuOutlined" />
      <ProFormText name="component" label="组件路径" placeholder="可选" />
      <ProFormDigit name="sort" label="排序" initialValue={0} />
      <ProFormSelect
        name="status"
        label="状态"
        initialValue="visible"
        options={[
          { value: 'visible', label: '显示' },
          { value: 'hidden', label: '隐藏' },
        ]}
      />
    </>
  )

  return (
    <AdminLayout>
      <Head title="菜单管理" />
      <AdminPageContainer title="菜单管理">
        <ProListPage<Menu>
          rowKey="id"
          columns={columns}
          data={menus}
          apiBase="/admin/menus"
          formItemsFor={formItemsFor}
        />
      </AdminPageContainer>
    </AdminLayout>
  )
}

export default MenusPage
