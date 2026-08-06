import { Head } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormDigit, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type Dept = {
  id: number
  name: string
  leader: string
  phone: string
  email: string
  sort: number
  status: 'enabled' | 'disabled'
}

const mockData: Dept[] = [
  { id: 1, name: '研发部', leader: '郑一', phone: '13800000001', email: 'rd@qingwuxu.cn', sort: 1, status: 'enabled' },
  { id: 2, name: '市场部', leader: '刘三', phone: '13800000002', email: 'mkt@qingwuxu.cn', sort: 2, status: 'enabled' },
  { id: 3, name: '财务部', leader: '杨八', phone: '13800000003', email: 'fin@qingwuxu.cn', sort: 3, status: 'enabled' },
  { id: 4, name: '人事部', leader: '方二', phone: '13800000004', email: 'hr@qingwuxu.cn', sort: 4, status: 'enabled' },
  { id: 5, name: '运维组', leader: '钱七', phone: '13800000005', email: 'ops@qingwuxu.cn', sort: 5, status: 'enabled' },
  { id: 6, name: '测试组', leader: '陈七', phone: '13800000006', email: 'qa@qingwuxu.cn', sort: 6, status: 'disabled' },
]

const columns: ProColumns<Dept>[] = [
  { title: '部门名称', dataIndex: 'name', search: true },
  { title: '负责人', dataIndex: 'leader' },
  { title: '联系电话', dataIndex: 'phone' },
  { title: '邮箱', dataIndex: 'email', ellipsis: true },
  { title: '排序', dataIndex: 'sort' },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => <Tag color={r.status === 'enabled' ? 'success' : 'error'}>{r.status === 'enabled' ? '启用' : '禁用'}</Tag>,
  },
]

const formItems = (
  <>
    <ProFormText name="name" label="部门名称" rules={[{ required: true, message: '请输入部门名称' }]} />
    <ProFormText name="leader" label="负责人" />
    <ProFormText name="phone" label="联系电话" />
    <ProFormText name="email" label="邮箱" rules={[{ type: 'email', message: '邮箱格式不正确' }]} />
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

export default function DepartmentsPage() {
  return (
    <AdminLayout>
      <Head title="部门管理" />
      <AdminPageContainer title="部门管理">
        <ProListPage<Dept> rowKey="id" columns={columns} mockData={mockData} formItems={formItems} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
