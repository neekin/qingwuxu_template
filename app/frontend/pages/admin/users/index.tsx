import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

// 真实字段对齐后端 User 模型（users 表无 nickname/dept 列，由后端聚合 roles 名称）
type User = {
  id: number
  username: string
  email: string | null
  phone: string
  role: string
  department?: string
  status: 'enabled' | 'disabled'
  super_admin: boolean
  created_at: string
}

const columns: ProColumns<User>[] = [
  { title: '用户名', dataIndex: 'username', search: true },
  { title: '邮箱', dataIndex: 'email' },
  { title: '手机号', dataIndex: 'phone' },
  { title: '角色', dataIndex: 'role' },
  {
    title: '部门',
    dataIndex: 'department',
    search: false,
    render: (_, r) => (r.department ? <Tag color="blue">{r.department}</Tag> : <Tag>—</Tag>),
  },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => (
      <Tag color={r.status === 'enabled' ? 'success' : 'error'}>{r.status === 'enabled' ? '启用' : '禁用'}</Tag>
    ),
  },
  {
    title: '超级管理员',
    dataIndex: 'super_admin',
    search: false,
    render: (_, r) => (r.super_admin ? <Tag color="gold">是</Tag> : <Tag>否</Tag>),
  },
  { title: '创建时间', dataIndex: 'created_at' },
]

const formItems = (
  <>
    <ProFormText name="username" label="用户名" rules={[{ required: true, message: '请输入用户名' }]} />
    <ProFormText name="email" label="邮箱" rules={[{ type: 'email', message: '邮箱格式不正确' }]} />
    <ProFormText
      name="phone"
      label="手机号"
      rules={[{ pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' }]}
    />
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

export default function UsersPage() {
  const page = usePage()
  const users = (page.props as Record<string, unknown>).users as User[]
  return (
    <AdminLayout>
      <Head title="用户管理" />
      <AdminPageContainer title="用户管理">
        <ProListPage<User> rowKey="id" columns={columns} data={users} formItems={formItems} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
