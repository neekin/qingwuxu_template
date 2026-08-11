import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormTextArea, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

// 真实字段对齐后端 Role 模型（description 映射为 remark 以复用列表列定义）
type Role = {
  id: number
  name: string
  code: string
  permissionCount: number
  permission_ids?: number[]
  remark: string | null
  created_at: string
}

type PermOption = { id: number; code: string; name: string }

const columns: ProColumns<Role>[] = [
  { title: '角色名称', dataIndex: 'name', search: true },
  { title: '权限字符', dataIndex: 'code' },
  { title: '权限点数', dataIndex: 'permissionCount', search: false },
  {
    title: '备注',
    dataIndex: 'remark',
    ellipsis: true,
    render: (_, r) => (r.remark ? <Tag color="blue">{r.remark}</Tag> : <Tag>—</Tag>),
  },
  { title: '创建时间', dataIndex: 'created_at' },
]

export default function RolesPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const roles = (props.roles as Role[]) || []
  const allPermissions = (props.all_permissions as PermOption[]) || []

  const formItemsFor = (_record?: Role) => (
    <>
      <ProFormText name="name" label="角色名称" rules={[{ required: true, message: '请输入角色名称' }]} />
      <ProFormText name="code" label="权限字符" rules={[{ required: true, message: '请输入权限字符' }]} />
      <ProFormSelect
        name="permission_ids"
        label="权限点"
        mode="multiple"
        options={allPermissions.map((p) => ({ value: p.id, label: `${p.name}（${p.code}）` }))}
      />
      <ProFormTextArea name="description" label="备注" />
    </>
  )

  return (
    <AdminLayout>
      <Head title="角色管理" />
      <AdminPageContainer title="角色管理">
        <ProListPage<Role>
          rowKey="id"
          columns={columns}
          data={roles}
          apiBase="/admin/roles"
          formItemsFor={formItemsFor}
        />
      </AdminPageContainer>
    </AdminLayout>
  )
}
