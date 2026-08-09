import { usePage, router } from '@inertiajs/react'
import { App, Table, Button, Tag, Typography } from 'antd'
import type { ColumnsType } from 'antd/es/table'

type OnlineUser = {
  id: number
  username: string | null
  phone: string | null
  department_name: string | null
  ip: string | null
  created_at: string
  last_seen_at: string | null
}

export default function OnlineUsersIndex() {
  const { props } = usePage<{ online_users: OnlineUser[] }>()
  const onlineUsers = props.online_users || []

  // antd v6：用 App.useApp() 取 message，避免静态方法无法消费主题 context 的告警。
  const { message } = App.useApp()

  const handleForceOffline = (id: number) => {
    router.delete(`/admin/online_users/${id}`, {
      onSuccess: () => message.success('已强制下线'),
      onError: () => message.error('强制下线失败'),
    })
  }

  const columns: ColumnsType<OnlineUser> = [
    { title: '用户', dataIndex: 'username', key: 'username' },
    { title: '手机号', dataIndex: 'phone', key: 'phone' },
    {
      title: '部门',
      dataIndex: 'department_name',
      key: 'department_name',
      render: (v) => v || <Tag>未分配</Tag>,
    },
    { title: '登录IP', dataIndex: 'ip', key: 'ip' },
    { title: '登录时间', dataIndex: 'created_at', key: 'created_at' },
    {
      title: '最后访问',
      dataIndex: 'last_seen_at',
      key: 'last_seen_at',
      render: (v) => v || '-',
    },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Button danger size="small" onClick={() => handleForceOffline(record.id)}>
          强制下线
        </Button>
      ),
    },
  ]

  return (
    <div style={{ padding: 24 }}>
      <Typography.Title level={4}>在线用户</Typography.Title>
      <Table rowKey="id" columns={columns} dataSource={onlineUsers} />
    </div>
  )
}
