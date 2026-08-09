import { useState } from 'react'
import { App, Button, Card, Form, Input, Typography, theme } from 'antd'
import { LockOutlined, MailOutlined, MobileOutlined, UserOutlined } from '@ant-design/icons'
import { router } from '@inertiajs/react'

const { Title, Text } = Typography

const csrfToken = () =>
  (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement | null)?.content || ''

// 后台注册页（手机为主，中国人习惯）。走 Inertia/React 栈，与前台隔离。
export default function Register() {
  const { token } = theme.useToken()
  const { message } = App.useApp()
  const [form] = Form.useForm()
  const [submitting, setSubmitting] = useState(false)
  const [countdown, setCountdown] = useState(0)

  const sendCode = async () => {
    const phone = form.getFieldValue('phone')
    if (!phone || !/^1[3-9]\d{9}$/.test(phone)) {
      message.error('请输入正确的手机号')
      return
    }
    try {
      const res = await fetch('/admin/login/send_code', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken() },
        body: JSON.stringify({ receiver: phone, channel: 'sms', purpose: 'register' }),
      })
      const data = await res.json()
      if (data.ok) {
        message.success(data.dev_code ? `验证码已发送（开发码：${data.dev_code}）` : '验证码已发送')
        let n = 60
        setCountdown(n)
        const timer = setInterval(() => {
          n -= 1
          setCountdown(n)
          if (n <= 0) clearInterval(timer)
        }, 1000)
      } else {
        message.error(data.error || '发送失败')
      }
    } catch {
      message.error('网络错误')
    }
  }

  const onFinish = (values: any) => {
    setSubmitting(true)
    router.post(
      '/admin/register',
      {
        phone: values.phone,
        code: values.code,
        password: values.password,
        username: values.username,
        email: values.email,
      },
      { onFinish: () => setSubmitting(false), onError: () => setSubmitting(false) }
    )
  }

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
          {/* 品牌面板 */}
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
                入驻一方天地
              </Title>
              <Text style={{ color: 'rgba(255,255,255,0.82)', fontSize: 14, lineHeight: 1.9 }}>
                以手机为凭，验明身份即入此门；RBAC 为经、设计系统为皮，秩序自现。
              </Text>
            </div>
            <Text style={{ color: 'rgba(255,255,255,0.6)', fontSize: 12, marginTop: 32 }}>
              © {new Date().getFullYear()} 青乌序 · 气乘风散，脉遇水止
            </Text>
          </div>

          {/* 表单面板 */}
          <div style={{ flex: '1 1 360px', minWidth: 300, padding: '48px 40px', background: token.colorBgContainer }}>
            <Title level={4} style={{ marginBottom: 4 }}>
              申请入驻
            </Title>
            <Text type="secondary">以手机号为主，验证码验明身份后即可设置密码。</Text>
            <Form form={form} layout="vertical" requiredMark={false} onFinish={onFinish} style={{ marginTop: 24 }}>
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
              <Form.Item
                label="设置密码"
                name="password"
                rules={[{ required: true, message: '请输入密码' }, { min: 6, message: '密码至少 6 位' }]}
              >
                <Input.Password prefix={<LockOutlined />} size="large" placeholder="请设置登录密码" />
              </Form.Item>
              <Form.Item label="用户名" name="username" rules={[{ required: true, message: '请输入用户名' }]}>
                <Input prefix={<UserOutlined />} size="large" placeholder="用于用户名密码登录" />
              </Form.Item>
              <Form.Item label="邮箱（选填）" name="email" rules={[{ type: 'email', message: '邮箱格式不正确' }]}>
                <Input prefix={<MailOutlined />} size="large" placeholder="you@company.com" />
              </Form.Item>
              <Button type="primary" htmlType="submit" size="large" block loading={submitting}>
                注 册
              </Button>
              <div style={{ textAlign: 'center', marginTop: 16 }}>
                <Text type="secondary" style={{ fontSize: 13 }}>
                  已有账号？
                  <a onClick={() => router.visit('/admin/login')} style={{ cursor: 'pointer', marginLeft: 4 }}>
                    直接登录
                  </a>
                </Text>
              </div>
            </Form>
          </div>
        </div>
      </Card>
    </div>
  )
}
