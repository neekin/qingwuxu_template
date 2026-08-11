import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import type { ProColumns } from '@ant-design/pro-components'

// 真实字段对齐后端 LoginLog 模型（由 SessionsController 登录成败时记录）。
type LoginLog = {
  id: number
  username: string | null
  ip: string | null
  user_agent: string | null
  login_type: string | null
  status: 'success' | 'fail'
  message: string | null
  created_at: string
}

const typeLabel: Record<string, string> = {
  password: '密码',
  sms: '短信验证码',
  register: '注册',
}

const columns: ProColumns<LoginLog>[] = [
  { title: '用户名', dataIndex: 'username', search: true },
  { title: '登录 IP', dataIndex: 'ip', search: false },
  {
    title: '登录方式',
    dataIndex: 'login_type',
    search: false,
    render: (_, r) => <Tag>{r.login_type ? (typeLabel[r.login_type] || r.login_type) : '—'}</Tag>,
  },
  {
    title: '状态',
    dataIndex: 'status',
    search: false,
    render: (_, r) => <Tag color={r.status === 'success' ? 'success' : 'error'}>{r.status === 'success' ? '成功' : '失败'}</Tag>,
  },
  {
    title: '客户端',
    dataIndex: 'user_agent',
    search: false,
    ellipsis: true,
    render: (_, r) => (r.user_agent ? <span style={{ fontSize: 12 }}>{r.user_agent}</span> : '—'),
  },
  { title: '登录时间', dataIndex: 'created_at', search: false },
]

export default function LoginLogsPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const loginLogs = (props.login_logs as LoginLog[]) || []

  return (
    <AdminLayout>
      <Head title="登录日志" />
      <AdminPageContainer title="登录日志">
        <ProListPage<LoginLog> rowKey="id" columns={columns} data={loginLogs} search={false} editable={false} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
