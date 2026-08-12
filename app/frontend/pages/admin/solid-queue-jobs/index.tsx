import { Head, usePage } from '@inertiajs/react'
import { Card, Statistic, Row, Col, Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import type { ProColumns } from '@ant-design/pro-components'

type QueueJob = {
  id: number
  class_name: string | null
  queue_name: string | null
  priority: number | null
  status: 'pending' | 'running' | 'failed' | 'finished'
  created_at: string
}

const statusMeta: Record<QueueJob['status'], { label: string; color: string }> = {
  pending: { label: '待执行', color: 'default' },
  running: { label: '进行中', color: 'processing' },
  failed: { label: '失败', color: 'error' },
  finished: { label: '已完成', color: 'success' },
}

const columns: ProColumns<QueueJob>[] = [
  { title: '任务类', dataIndex: 'class_name', search: false, ellipsis: true },
  { title: '队列', dataIndex: 'queue_name', search: false },
  { title: '优先级', dataIndex: 'priority', search: false },
  {
    title: '状态',
    dataIndex: 'status',
    search: false,
    render: (_, r) => {
      const m = statusMeta[r.status]
      return <Tag color={m.color}>{m.label}</Tag>
    },
  },
  { title: '入队时间', dataIndex: 'created_at', search: false },
]

export default function SolidQueueJobsPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const stats = (props.stats as Record<string, number>) || {}
  const jobs = (props.jobs as QueueJob[]) || []

  return (
    <AdminLayout>
      <Head title="定时任务" />
      <AdminPageContainer title="定时任务监控">
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={6}>
            <Card>
              <Statistic title="待执行" value={stats.pending || 0} />
            </Card>
          </Col>
          <Col span={6}>
            <Card>
              <Statistic title="进行中" value={stats.running || 0} valueStyle={{ color: '#1677ff' }} />
            </Card>
          </Col>
          <Col span={6}>
            <Card>
              <Statistic title="失败" value={stats.failed || 0} valueStyle={{ color: '#cf1322' }} />
            </Card>
          </Col>
          <Col span={6}>
            <Card>
              <Statistic title="已完成" value={stats.finished || 0} valueStyle={{ color: '#3f8600' }} />
            </Card>
          </Col>
        </Row>
        <ProListPage<QueueJob> rowKey="id" columns={columns} data={jobs} search={false} editable={false} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
