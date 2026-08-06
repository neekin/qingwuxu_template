import { Head } from '@inertiajs/react'
import { useState } from 'react'
import AdminLayout from '../../../layouts/AdminLayout'
import { Card, Statistic, Button, Input, Tabs, Typography, Divider, Space } from 'antd'

const { Paragraph, Text } = Typography

type Props = {
  rails_version: string
  ruby_version: string
  rack_version: string
  inertia_rails_version: string
}

// 后台演示页：集中展示 Inertia + React 的能力（已纳入统一 AdminLayout 壳）
export default function InertiaExample({
  rails_version,
  ruby_version,
  rack_version,
  inertia_rails_version,
}: Props) {
  const [count, setCount] = useState(0)
  const [name, setName] = useState('')
  const [items, setItems] = useState<string[]>([])

  const addItem = () => {
    const value = name.trim()
    if (!value) return
    setItems((prev) => [...prev, value])
    setName('')
  }

  return (
    <AdminLayout>
      <Head title="后台 · Inertia + React 演示" />
      <div style={{ maxWidth: 960, width: '100%', margin: '0 auto' }}>
        <Tabs
          defaultActiveKey="1"
          items={[
            {
              key: '1',
              label: '版本信息（服务端 props 注入）',
              children: (
                <div>
                  <Paragraph type="secondary">
                    以下四项由 Rails 通过 Inertia 的 props 注入，React 仅负责声明式渲染，无需手写 fetch。
                  </Paragraph>
                  <div
                    style={{
                      display: 'grid',
                      gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))',
                      gap: 16,
                    }}
                  >
                    <Card>
                      <Statistic title="Rails" value={rails_version} />
                    </Card>
                    <Card>
                      <Statistic title="Ruby" value={ruby_version} />
                    </Card>
                    <Card>
                      <Statistic title="Rack" value={rack_version} />
                    </Card>
                    <Card>
                      <Statistic title="inertia_rails" value={inertia_rails_version} />
                    </Card>
                  </div>
                </div>
              ),
            },
            {
              key: '2',
              label: 'React 交互演示',
              children: (
                <Space direction="vertical" size="large" style={{ width: '100%' }}>
                  <Card title="useState 计数器（声明式状态）">
                    <Space>
                      <Button type="primary" onClick={() => setCount((c) => c - 1)}>
                        −
                      </Button>
                      <Statistic value={count} style={{ width: 80, textAlign: 'center' }} />
                      <Button type="primary" onClick={() => setCount((c) => c + 1)}>
                        +
                      </Button>
                    </Space>
                  </Card>
                  <Card title="受控输入 + 动态列表">
                    <Space>
                      <Input
                        placeholder="输入一项，回车或点添加"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        onPressEnter={addItem}
                      />
                      <Button type="primary" onClick={addItem}>
                        添加
                      </Button>
                    </Space>
                    <Divider />
                    {items.length === 0 ? (
                      <Text type="secondary">列表为空，试试添加一项。</Text>
                    ) : (
                      <ul>
                        {items.map((it, i) => (
                          <li key={i}>{it}</li>
                        ))}
                      </ul>
                    )}
                  </Card>
                </Space>
              ),
            },
          ]}
        />
      </div>
    </AdminLayout>
  )
}
