import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import type { ProColumns } from '@ant-design/pro-components'

// 真实字段对齐后端 OperationLog 模型（由 BaseController 自动记录）。
type OperationLog = {
  id: number
  username: string | null
  ip: string | null
  request_method: string | null
  path: string | null
  action: string | null
  title: string | null
  status: 'success' | 'fail'
  duration_ms: number | null
  created_at: string
}

const methodColor: Record<string, string> = {
  GET: 'default',
  POST: 'green',
  PUT: 'blue',
  PATCH: 'blue',
  DELETE: 'red',
}

const columns: ProColumns<OperationLog>[] = [
  { title: '操作', dataIndex: 'title', search: true },
  {
    title: '请求方式',
    dataIndex: 'request_method',
    search: false,
    render: (_, r) =>
      r.request_method ? <Tag color={methodColor[r.request_method] || 'default'}>{r.request_method}</Tag> : <Tag>—</Tag>,
  },
  { title: '操作人', dataIndex: 'username', search: true },
  { title: 'IP', dataIndex: 'ip', search: false },
  {
    title: '状态',
    dataIndex: 'status',
    search: false,
    render: (_, r) => <Tag color={r.status === 'success' ? 'success' : 'error'}>{r.status === 'success' ? '成功' : '失败'}</Tag>,
  },
  {
    title: '耗时',
    dataIndex: 'duration_ms',
    search: false,
    render: (_, r) => (r.duration_ms != null ? `${r.duration_ms} ms` : '—'),
  },
  { title: '操作时间', dataIndex: 'created_at', search: false },
]

export default function OperationLogsPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const operationLogs = (props.operation_logs as OperationLog[]) || []

  return (
    <AdminLayout>
      <Head title="操作日志" />
      <AdminPageContainer title="操作日志">
        <ProListPage<OperationLog> rowKey="id" columns={columns} data={operationLogs} search={false} editable={false} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
