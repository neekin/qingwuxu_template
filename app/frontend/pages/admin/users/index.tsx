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
  role_ids?: number[]
  department?: string
  department_id?: number | null
  status: 'enabled' | 'disabled'
  super_admin: boolean
  created_at: string
}

type Option = { id: number; name: string }

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

// formItems 为函数：编辑时回填已有的角色/部门（由 ProListPage 的 formItemsFor 机制注入 record）
export default function UsersPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const users = (props.users as User[]) || []
  const allRoles = (props.all_roles as Option[]) || []
  const allDepartments = (props.all_departments as Option[]) || []

  const formItemsFor = (_record?: User) => (
    <>
      <ProFormText name="username" label="用户名" rules={[{ required: true, message: '请输入用户名' }]} />
      <ProFormText name="email" label="邮箱" rules={[{ type: 'email', message: '邮箱格式不正确' }]} />
      <ProFormText
        name="phone"
        label="手机号"
        rules={[{ required: true, message: '请输入手机号' }, { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' }]}
      />
      <ProFormText.Password
        name="password"
        label="密码"
        placeholder="留空则不修改"
        rules={[{ min: 6, message: '至少 6 位' }]}
      />
      <ProFormSelect
        name="role_ids"
        label="角色"
        mode="multiple"
        options={allRoles.map((r) => ({ value: r.id, label: r.name }))}
      />
      <ProFormSelect
        name="department_id"
        label="部门"
        allowClear
        options={allDepartments.map((d) => ({ value: d.id, label: d.name }))}
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

  return (
    <AdminLayout>
      <Head title="用户管理" />
      <AdminPageContainer title="用户管理">
        <ProListPage<User>
          rowKey="id"
          columns={columns}
          data={users}
          apiBase="/admin/users"
          formItemsFor={formItemsFor}
        />
      </AdminPageContainer>
    </AdminLayout>
  )
}
