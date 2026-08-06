import { Head } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import type { ProColumns } from '@ant-design/pro-components'

type OperLog = {
  id: number
  title: string
  businessType: 'create' | 'update' | 'delete' | 'query' | 'export'
  method: string
  operator: string
  ip: string
  time: string
  status: 'success' | 'fail'
}

const bizMap: Record<OperLog['businessType'], { text: string; color: string }> = {
  create: { text: '新增', color: 'green' },
  update: { text: '修改', color: 'blue' },
  delete: { text: '删除', color: 'red' },
  query: { text: '查询', color: 'default' },
  export: { text: '导出', color: 'orange' },
}

const mockData: OperLog[] = [
  { id: 1, title: '新增用户「王五」', businessType: 'create', method: 'POST', operator: '李四', ip: '192.168.1.21', time: '2026-08-06 10:03', status: 'success' },
  { id: 2, title: '修改角色「运维」', businessType: 'update', method: 'PUT', operator: '管理员', ip: '192.168.1.10', time: '2026-08-06 11:20', status: 'success' },
  { id: 3, title: '删除菜单「测试」', businessType: 'delete', method: 'DELETE', operator: '钱七', ip: '192.168.1.33', time: '2026-08-06 16:30', status: 'success' },
  { id: 4, title: '导出操作日志', businessType: 'export', method: 'GET', operator: '赵六', ip: '192.168.1.45', time: '2026-08-06 14:45', status: 'success' },
  { id: 5, title: '查询用户列表', businessType: 'query', method: 'GET', operator: '王五', ip: '192.168.1.21', time: '2026-08-06 09:50', status: 'success' },
  { id: 6, title: '修改用户「孙八」', businessType: 'update', method: 'PUT', operator: '管理员', ip: '192.168.1.10', time: '2026-08-05 18:12', status: 'fail' },
  { id: 7, title: '新增部门「测试组」', businessType: 'create', method: 'POST', operator: '方二', ip: '192.168.1.50', time: '2026-08-05 15:33', status: 'success' },
  { id: 8, title: '删除角色「访客」', businessType: 'delete', method: 'DELETE', operator: '钱七', ip: '192.168.1.33', time: '2026-08-05 13:01', status: 'success' },
  { id: 9, title: '导出用户数据', businessType: 'export', method: 'GET', operator: '杨八', ip: '192.168.1.60', time: '2026-08-04 20:41', status: 'success' },
  { id: 10, title: '修改菜单「用户管理」', businessType: 'update', method: 'PUT', operator: '管理员', ip: '192.168.1.10', time: '2026-08-04 11:09', status: 'success' },
  { id: 11, title: '查询操作日志', businessType: 'query', method: 'GET', operator: '赵六', ip: '192.168.1.45', time: '2026-08-04 09:22', status: 'success' },
  { id: 12, title: '新增用户失败', businessType: 'create', method: 'POST', operator: '刘三', ip: '192.168.1.70', time: '2026-08-03 17:55', status: 'fail' },
]

const columns: ProColumns<OperLog>[] = [
  { title: '操作模块', dataIndex: 'title', search: true },
  {
    title: '业务类型',
    dataIndex: 'businessType',
    render: (_, r) => <Tag color={bizMap[r.businessType].color}>{bizMap[r.businessType].text}</Tag>,
  },
  { title: '请求方式', dataIndex: 'method' },
  { title: '操作人', dataIndex: 'operator' },
  { title: 'IP 地址', dataIndex: 'ip' },
  { title: '操作时间', dataIndex: 'time' },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => <Tag color={r.status === 'success' ? 'success' : 'error'}>{r.status === 'success' ? '成功' : '失败'}</Tag>,
  },
]

export default function OperationLogsPage() {
  return (
    <AdminLayout>
      <Head title="操作日志" />
      <AdminPageContainer title="操作日志">
        <ProListPage<OperLog> rowKey="id" columns={columns} mockData={mockData} editable={false} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
