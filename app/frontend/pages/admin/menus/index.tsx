import { Head } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormSelect, ProFormDigit } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type Menu = {
  id: number
  title: string
  type: 'catalog' | 'menu' | 'button'
  path: string
  permission: string
  sort: number
  status: 'enabled' | 'disabled'
}

const typeMap: Record<Menu['type'], { text: string; color: string }> = {
  catalog: { text: '目录', color: 'default' },
  menu: { text: '菜单', color: 'blue' },
  button: { text: '按钮', color: 'geekblue' },
}

const mockData: Menu[] = [
  { id: 1, title: '系统管理', type: 'catalog', path: '/admin/system', permission: 'system:manage', sort: 1, status: 'enabled' },
  { id: 2, title: '用户管理', type: 'menu', path: '/admin/users', permission: 'system:user:list', sort: 1, status: 'enabled' },
  { id: 3, title: '角色管理', type: 'menu', path: '/admin/roles', permission: 'system:role:list', sort: 2, status: 'enabled' },
  { id: 4, title: '菜单管理', type: 'menu', path: '/admin/menus', permission: 'system:menu:list', sort: 3, status: 'enabled' },
  { id: 5, title: '部门管理', type: 'menu', path: '/admin/departments', permission: 'system:dept:list', sort: 4, status: 'enabled' },
  { id: 6, title: '新增用户', type: 'button', path: '', permission: 'system:user:add', sort: 1, status: 'enabled' },
  { id: 7, title: '系统监控', type: 'catalog', path: '/admin/monitor', permission: 'monitor:manage', sort: 2, status: 'enabled' },
  { id: 8, title: '操作日志', type: 'menu', path: '/admin/operation-logs', permission: 'monitor:operlog:list', sort: 1, status: 'enabled' },
  { id: 9, title: '登录日志', type: 'menu', path: '/admin/login-logs', permission: 'monitor:loginlog:list', sort: 2, status: 'enabled' },
  { id: 10, title: '个人中心', type: 'menu', path: '/admin/profile', permission: 'user:profile:view', sort: 3, status: 'enabled' },
  { id: 11, title: '测试菜单', type: 'menu', path: '/admin/test', permission: 'test:list', sort: 5, status: 'disabled' },
]

const columns: ProColumns<Menu>[] = [
  { title: '菜单名称', dataIndex: 'title', search: true },
  {
    title: '类型',
    dataIndex: 'type',
    render: (_, r) => <Tag color={typeMap[r.type].color}>{typeMap[r.type].text}</Tag>,
  },
  { title: '路由地址', dataIndex: 'path', ellipsis: true },
  { title: '权限字符', dataIndex: 'permission', ellipsis: true },
  { title: '排序', dataIndex: 'sort' },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => <Tag color={r.status === 'enabled' ? 'success' : 'error'}>{r.status === 'enabled' ? '启用' : '禁用'}</Tag>,
  },
]

const formItems = (
  <>
    <ProFormText name="title" label="菜单名称" rules={[{ required: true, message: '请输入菜单名称' }]} />
    <ProFormSelect
      name="type"
      label="类型"
      initialValue="menu"
      options={[
        { value: 'catalog', label: '目录' },
        { value: 'menu', label: '菜单' },
        { value: 'button', label: '按钮' },
      ]}
    />
    <ProFormText name="path" label="路由地址" />
    <ProFormText name="permission" label="权限字符" />
    <ProFormDigit name="sort" label="排序" initialValue={1} />
    <ProFormSelect
      name="status"
      label="状态"
      initialValue="enabled"
      options={[
        { value: 'enabled', label: '启用' },
        { value: 'disabled', label: '禁用' },
      ]}
    />
  </>
)

export default function MenusPage() {
  return (
    <AdminLayout>
      <Head title="菜单管理" />
      <AdminPageContainer title="菜单管理">
        <ProListPage<Menu> rowKey="id" columns={columns} mockData={mockData} formItems={formItems} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
