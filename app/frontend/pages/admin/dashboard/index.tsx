import { Head } from '@inertiajs/react'
import { Avatar } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import { ProCard, Statistic } from '@ant-design/pro-components'
import { List } from 'antd'
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons'

const stats = [
  { title: '总用户数', value: 1280, suffix: '人', trend: 12.5 },
  { title: '今日访问', value: 342, suffix: '次', trend: 8.2 },
  { title: '待办事项', value: 18, suffix: '项', trend: -3.1 },
  { title: '系统负载', value: 42, suffix: '%', trend: 1.4 },
]

const recent = [
  { id: 1, user: '张三', action: '登录系统', time: '2026-08-06 09:12' },
  { id: 2, user: '李四', action: '新增用户「王五」', time: '2026-08-06 10:03' },
  { id: 3, user: '管理员', action: '修改角色「运维」', time: '2026-08-06 11:20' },
  { id: 4, user: '赵六', action: '导出操作日志', time: '2026-08-06 14:45' },
  { id: 5, user: '钱七', action: '删除菜单「测试」', time: '2026-08-06 16:30' },
]

export default function DashboardPage() {
  return (
    <AdminLayout>
      <Head title="仪表盘" />
      <AdminPageContainer title="仪表盘">
        <ProCard gutter={16} wrap style={{ marginBottom: 16 }}>
          {stats.map((s) => (
            <ProCard key={s.title} colSpan={6}>
              <Statistic title={s.title} value={s.value} suffix={s.suffix} valueStyle={{ color: '#1B6E78' }} />
              <div style={{ marginTop: 8, color: s.trend >= 0 ? '#1F9D6B' : '#D43829', fontSize: 13 }}>
                {s.trend >= 0 ? <ArrowUpOutlined /> : <ArrowDownOutlined />} {Math.abs(s.trend)}% 较昨日
              </div>
            </ProCard>
          ))}
        </ProCard>
        <ProCard title="最近操作">
          <List
            dataSource={recent}
            renderItem={(item) => (
              <List.Item>
                <List.Item.Meta
                  avatar={<Avatar style={{ backgroundColor: '#1B6E78' }}>{item.user.slice(0, 1)}</Avatar>}
                  title={`${item.user} · ${item.action}`}
                  description={item.time}
                />
              </List.Item>
            )}
          />
        </ProCard>
      </AdminPageContainer>
    </AdminLayout>
  )
}
