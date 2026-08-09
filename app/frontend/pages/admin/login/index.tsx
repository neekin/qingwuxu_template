import { useState } from 'react'
import { Alert, App, Button, Card, Checkbox, Form, Input, Tabs, Typography, theme } from 'antd'
import { LockOutlined, MailOutlined, MobileOutlined, UserOutlined } from '@ant-design/icons'
import { router } from '@inertiajs/react'

const { Title, Text, Paragraph } = Typography

const csrfToken = () =>
  (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement | null)?.content || ''

// 后台登录页（独立全屏，不套 AdminLayout 侧栏；走 Inertia/React 栈，与前台隔离）。
// 三种登录方式（中国人习惯，手机验证码置顶）：手机验证码 / 用户名密码 / 邮箱密码。
export default function Login() {
  const { token } = theme.useToken()
  const { message } = App.useApp()
  const [submitting, setSubmitting] = useState(false)
  const [activeTab, setActiveTab] = useState('sms')
  const [smsForm] = Form.useForm()
  const [pwdForm] = Form.useForm()
  const [mailForm] = Form.useForm()
  const [countdown, setCountdown] = useState(0)

  const startCountdown = () => {
    let n = 60
    setCountdown(n)
    const timer = setInterval(() => {
      n -= 1
      setCountdown(n)
      if (n <= 0) clearInterval(timer)
    }, 1000)
  }

  // 获取验证码（普通 XHR，带 CSRF；开发期 Mock 不发真实短信，码通过 message 提示）。
  const sendCode = async () => {
    const form = activeTab === 'sms' ? smsForm : mailForm
    const receiver = form.getFieldValue(activeTab === 'sms' ? 'phone' : 'email')
    const channel = activeTab === 'sms' ? 'sms' : 'email'
    if (!receiver || (activeTab === 'sms' && !/^1[3-9]\d{9}$/.test(receiver))) {
      message.error(activeTab === 'sms' ? '请输入正确的手机号' : '请输入正确的邮箱')
      return
    }
    try {
      const res = await fetch('/admin/login/send_code', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken() },
        body: JSON.stringify({ receiver, channel, purpose: 'login' }),
      })
      const data = await res.json()
      if (data.ok) {
        message.success(data.dev_code ? `验证码已发送（开发码：${data.dev_code}）` : '验证码已发送')
        startCountdown()
      } else {
        message.error(data.error || '发送失败')
      }
    } catch {
      message.error('网络错误')
    }
  }

  const submit = (values: any, loginType: 'sms' | 'username' | 'email') => {
    setSubmitting(true)
    const payload: any = { login_type: loginType, remember: values.remember !== false }
    if (loginType === 'sms') {
      payload.phone = values.phone
      payload.code = values.code
    } else {
      payload.account = loginType === 'email' ? values.email : values.account
      payload.password = values.password
    }
    router.post('/admin/login', payload, {
      onFinish: () => setSubmitting(false),
      onError: () => setSubmitting(false),
    })
  }

  const footer = (
    <>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <Form.Item name="remember" valuePropName="checked" initialValue={true} style={{ marginBottom: 0 }}>
          <Checkbox>记住我</Checkbox>
        </Form.Item>
        <a href="#" style={{ fontSize: 13 }}>
          忘记密码？
        </a>
      </div>
      <Button type="primary" htmlType="submit" size="large" block loading={submitting}>
        登 录
      </Button>
      <div style={{ textAlign: 'center', marginTop: 16 }}>
        <Text type="secondary" style={{ fontSize: 13 }}>
          还没有账号？
          <a onClick={() => router.visit('/admin/register')} style={{ cursor: 'pointer', marginLeft: 4 }}>
            立即注册
          </a>
        </Text>
      </div>
    </>
  )

  const tabItems = [
    {
      key: 'sms',
      label: '手机验证码',
      children: (
        <Form form={smsForm} layout="vertical" requiredMark={false} onFinish={(v) => submit(v, 'sms')}>
          <Form.Item
            label="手机号"
            name="phone"
            rules={[{ required: true, message: '请输入手机号' }, { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' }]}
          >
            <Input prefix={<MobileOutlined />} size="large" placeholder="请输入手机号" />
          </Form.Item>
          <Form.Item label="验证码" name="code" rules={[{ required: true, message: '请输入验证码' }]}>
            <Input
              prefix={<LockOutlined />}
              size="large"
              placeholder="请输入验证码"
              addonAfter={
                <Button type="link" size="small" htmlType="button" disabled={countdown > 0} onClick={sendCode} style={{ padding: 0 }}>
                  {countdown > 0 ? `${countdown}s 后重发` : '获取验证码'}
                </Button>
              }
            />
          </Form.Item>
          {footer}
        </Form>
      ),
    },
    {
      key: 'username',
      label: '用户名密码',
      children: (
        <Form form={pwdForm} layout="vertical" requiredMark={false} onFinish={(v) => submit(v, 'username')}>
          <Form.Item label="用户名" name="account" rules={[{ required: true, message: '请输入用户名' }]}>
            <Input prefix={<UserOutlined />} size="large" placeholder="请输入用户名" />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password prefix={<LockOutlined />} size="large" placeholder="请输入密码" />
          </Form.Item>
          {footer}
        </Form>
      ),
    },
    {
      key: 'email',
      label: '邮箱密码',
      children: (
        <Form form={mailForm} layout="vertical" requiredMark={false} onFinish={(v) => submit(v, 'email')}>
          <Form.Item
            label="邮箱"
            name="email"
            rules={[{ required: true, message: '请输入邮箱' }, { type: 'email', message: '邮箱格式不正确' }]}
          >
            <Input prefix={<MailOutlined />} size="large" placeholder="you@company.com" />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password prefix={<LockOutlined />} size="large" placeholder="请输入密码" />
          </Form.Item>
          {footer}
        </Form>
      ),
    },
  ]

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: token.colorBgLayout,
        padding: 16,
      }}
    >
      <Card variant="borderless" style={{ width: '100%', maxWidth: 920, overflow: 'hidden' }} styles={{ body: { padding: 0 } }}>
        <div style={{ display: 'flex', flexWrap: 'wrap' }}>
          {/* 品牌面板（黛青渐变，与主色令牌对齐） */}
          <div
            style={{
              flex: '1 1 320px',
              minWidth: 280,
              background: 'linear-gradient(135deg, #1B6E78 0%, #15565e 100%)',
              color: '#fff',
              padding: '48px 36px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
            }}
          >
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <span
                  style={{
                    display: 'inline-grid',
                    placeItems: 'center',
                    width: 40,
                    height: 40,
                    borderRadius: 8,
                    background: '#BF8430',
                    fontWeight: 700,
                  }}
                >
                  青
                </span>
                <span style={{ fontSize: 22, fontWeight: 600, letterSpacing: 2 }}>青乌序</span>
              </div>
              <Title level={3} style={{ color: '#fff', marginTop: 28, marginBottom: 12 }}>
                为后台，勘一方秩序
              </Title>
              <Paragraph style={{ color: 'rgba(255,255,255,0.82)', fontSize: 14, lineHeight: 1.9, marginBottom: 0 }}>
                青乌序，古之堪舆奇书，善辨山川脉络、裁穴有定。今以此为名，愿做你后台的「国师」——
                以 RBAC 为经、代码生成为纬、设计系统为皮，于混沌处立一方秩序，开箱即成序。
              </Paragraph>
            </div>
            <ul style={{ listStyle: 'none', padding: 0, margin: '32px 0 0', display: 'grid', gap: 14 }}>
              {[
                '寻龙：ActionPolicy 唯一授权，服务端为真相',
                '安位：前后台双栈隔离，各守其域',
                '成序：设计系统与生成器，皆已就位',
              ].map((t) => (
                <li key={t} style={{ display: 'flex', alignItems: 'center', gap: 10, color: 'rgba(255,255,255,0.9)', fontSize: 14 }}>
                  <span style={{ width: 6, height: 6, borderRadius: 99, background: '#BF8430' }} /> {t}
                </li>
              ))}
            </ul>
            <Text style={{ color: 'rgba(255,255,255,0.6)', fontSize: 12, marginTop: 32 }}>
              © {new Date().getFullYear()} 青乌序 · 气乘风散，脉遇水止
            </Text>
          </div>

          {/* 表单面板（三 Tab） */}
          <div style={{ flex: '1 1 360px', minWidth: 300, padding: '48px 40px', background: token.colorBgContainer }}>
            <Title level={4} style={{ marginBottom: 4 }}>
              入此门
            </Title>
            <Text type="secondary">支持手机号、用户名或邮箱登录（中国人习惯，验证码优先）。</Text>
            <Alert
              type="info"
              showIcon
              style={{ marginTop: 16 }}
              message="开发期提示"
              description="手机/邮箱验证码由 Mock 网关模拟发送，验证码会显示在页面提示中，无需真实短信。"
            />
            <Tabs activeKey={activeTab} onChange={setActiveTab} items={tabItems} style={{ marginTop: 12 }} />
          </div>
        </div>
      </Card>
    </div>
  )
}
