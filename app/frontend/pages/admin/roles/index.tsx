import { Head } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormDigit, ProFormTextArea } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type Role = {
  id: number
  name: string
  code: string
  permissionCount: number
  remark: string
  created_at: string
}

const mockData: Role[] = [
  { id: 1, name: '超级管理员', code: 'super_admin', permissionCount: 128, remark: '系统最高权限', created_at: '2026-01-02 10:00' },
  { id: 2, name: '管理员', code: 'admin', permissionCount: 64, remark: '日常运维管理', created_at: '2026-01-02 10:01' },
  { id: 3, name: '普通用户', code: 'user', permissionCount: 12, remark: '基础业务权限', created_at: '2026-01-02 10:02' },
  { id: 4, name: '审计员', code: 'auditor', permissionCount: 8, remark: '仅查看日志', created_at: '2026-03-15 14:20' },
  { id: 5, name: '运维', code: 'ops', permissionCount: 36, remark: '监控与部署', created_at: '2026-04-08 09:30' },
  { id: 6, name: '财务', code: 'finance', permissionCount: 20, remark: '财务相关模块', created_at: '2026-05-11 16:40' },
  { id: 7, name: '访客', code: 'guest', permissionCount: 3, remark: '只读预览', created_at: '2026-06-22 11:11' },
]

const columns: ProColumns<Role>[] = [
  { title: '角色名称', dataIndex: 'name', search: true },
  { title: '权限字符', dataIndex: 'code' },
  { title: '权限点数', dataIndex: 'permissionCount', search: false },
  {
    title: '备注',
    dataIndex: 'remark',
    ellipsis: true,
    render: (_, r) => <Tag color="blue">{r.remark}</Tag>,
  },
  { title: '创建时间', dataIndex: 'created_at' },
]

const formItems = (
  <>
    <ProFormText name="name" label="角色名称" rules={[{ required: true, message: '请输入角色名称' }]} />
    <ProFormText name="code" label="权限字符" rules={[{ required: true, message: '请输入权限字符' }]} />
    <ProFormDigit name="permissionCount" label="权限点数" initialValue={0} />
    <ProFormTextArea name="remark" label="备注" />
  </>
)

export default function RolesPage() {
  return (
    <AdminLayout>
      <Head title="角色管理" />
      <AdminPageContainer title="角色管理">
        <ProListPage<Role> rowKey="id" columns={columns} mockData={mockData} formItems={formItems} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
