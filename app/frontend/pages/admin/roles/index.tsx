import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormTextArea } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

// 真实字段对齐后端 Role 模型（description 映射为 remark 以复用列表列定义）
type Role = {
  id: number
  name: string
  code: string
  permissionCount: number
  remark: string | null
  created_at: string
}

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

const formItems = (
  <>
    <ProFormText name="name" label="角色名称" rules={[{ required: true, message: '请输入角色名称' }]} />
    <ProFormText name="code" label="权限字符" rules={[{ required: true, message: '请输入权限字符' }]} />
    <ProFormTextArea name="remark" label="备注" />
  </>
)

export default function RolesPage() {
  const page = usePage()
  const roles = (page.props as Record<string, unknown>).roles as Role[]
  return (
    <AdminLayout>
      <Head title="角色管理" />
      <AdminPageContainer title="角色管理">
        <ProListPage<Role> rowKey="id" columns={columns} data={roles} formItems={formItems} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
