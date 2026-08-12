import { Head, usePage } from '@inertiajs/react'
import { Card, Statistic, Row, Col, Typography } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'

const { Title } = Typography

type MonitorProps = {
  queue: { pending: number; running: number; failed: number; finished: number }
  cache: { entries: number }
  cable: { messages: number }
  app: { online_users: number; operation_logs_today: number; login_logs_today: number }
}

function StatCard({ title, value, color }: { title: string; value: number; color?: string }) {
  return (
    <Col span={6}>
      <Card>
        <Statistic title={title} value={value} valueStyle={color ? { color } : undefined} />
      </Card>
    </Col>
  )
}

export default function SystemMonitorPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const data = (props as unknown as MonitorProps) || {}

  return (
    <AdminLayout>
      <Head title="服务监控" />
      <AdminPageContainer title="服务监控看板">
        <Title level={5}>队列（Solid Queue）</Title>
        <Row gutter={16} style={{ marginBottom: 24 }}>
          <StatCard title="待执行" value={data.queue?.pending || 0} />
          <StatCard title="进行中" value={data.queue?.running || 0} color="#1677ff" />
          <StatCard title="失败" value={data.queue?.failed || 0} color="#cf1322" />
          <StatCard title="已完成" value={data.queue?.finished || 0} color="#3f8600" />
        </Row>

        <Title level={5}>缓存 / 电缆（Solid Cache / Cable）</Title>
        <Row gutter={16} style={{ marginBottom: 24 }}>
          <StatCard title="缓存条目" value={data.cache?.entries || 0} />
          <StatCard title="电缆消息" value={data.cable?.messages || 0} />
        </Row>

        <Title level={5}>应用运行指标</Title>
        <Row gutter={16}>
          <StatCard title="在线用户" value={data.app?.online_users || 0} color="#1677ff" />
          <StatCard title="今日操作日志" value={data.app?.operation_logs_today || 0} />
          <StatCard title="今日登录日志" value={data.app?.login_logs_today || 0} />
        </Row>
      </AdminPageContainer>
    </AdminLayout>
  )
}
