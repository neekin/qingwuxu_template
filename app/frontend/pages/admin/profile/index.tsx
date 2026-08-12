import { Head, usePage, router } from '@inertiajs/react'
import { App, Avatar, Button, Upload } from 'antd'
import type { UploadProps } from 'antd'
import { ModalForm, ProFormText, ProCard, ProDescriptions } from '@ant-design/pro-components'
import { UploadOutlined } from '@ant-design/icons'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'

type ProfileUser = {
  id: number
  username: string
  nickname: string | null
  email: string | null
  phone: string
  dept: string | null
  role: string
  avatar_url: string | null
  created_at: string
}

const ProfilePage = () => {
  const { message: msg } = App.useApp()
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const user = (props.user as ProfileUser) || {}

  // 头像上传前校验：仅图片 + 小于 2MB
  const beforeUpload: UploadProps['beforeUpload'] = (file) => {
    const isImage = file.type.startsWith('image/')
    if (!isImage) {
      msg.error('只能上传图片文件')
      return Upload.LIST_IGNORE
    }
    const isLt2M = file.size / 1024 / 1024 < 2
    if (!isLt2M) {
      msg.error('图片大小需小于 2MB')
      return Upload.LIST_IGNORE
    }
    return true
  }

  // 头像走 Inertia 多部件 PUT（Active Storage 本地磁盘）
  const customAvatarRequest = (options: any) => {
    const { file, onSuccess, onError } = options
    router.put(
      '/admin/profile',
      { avatar: file },
      {
        onSuccess: () => {
          msg.success('头像已更新')
          onSuccess?.('ok')
        },
        onError: () => {
          msg.error('头像上传失败')
          onError?.(new Error('upload failed'))
        },
      }
    )
  }

  const editInfo = (values: any) =>
    new Promise<boolean>((resolve) => {
      router.put('/admin/profile', values, {
        onSuccess: () => {
          msg.success('资料已更新')
          resolve(true)
        },
        onError: () => {
          msg.error('资料更新失败')
          resolve(false)
        },
      })
    })

  const changePwd = (values: any) =>
    new Promise<boolean>((resolve) => {
      if (values.newPassword !== values.confirm) {
        msg.error('两次输入的新密码不一致')
        resolve(false)
        return
      }
      router.put(
        '/admin/profile/change_password',
        { old_password: values.oldPassword, new_password: values.newPassword },
        {
          onSuccess: () => {
            msg.success('密码已修改')
            resolve(true)
          },
          onError: () => {
            msg.error('修改失败，请检查原密码')
            resolve(false)
          },
        }
      )
    })

  return (
    <AdminLayout>
      <Head title="个人中心" />
      <AdminPageContainer title="个人中心">
        <ProCard gutter={16} wrap>
          <ProCard colSpan={8}>
            <div style={{ textAlign: 'center' }}>
              <Avatar size={80} src={user.avatar_url || undefined} style={{ backgroundColor: '#1B6E78' }}>
                {(user.nickname || user.username || '管').toString().slice(0, 1)}
              </Avatar>
              <h2 style={{ margin: '12px 0 0' }}>{user.nickname || user.username}</h2>
              <p style={{ color: '#6E7E7E', margin: 0 }}>{user.role}</p>
              <Upload
                accept="image/*"
                showUploadList={false}
                beforeUpload={beforeUpload}
                customRequest={customAvatarRequest}
              >
                <Button icon={<UploadOutlined />} block style={{ marginTop: 16 }}>
                  更换头像
                </Button>
              </Upload>
              <ModalForm
                title="编辑资料"
                trigger={
                  <Button block style={{ marginTop: 8 }}>
                    编辑资料
                  </Button>
                }
                modalProps={{ destroyOnHidden: true }}
                initialValues={{ nickname: user.nickname, email: user.email, phone: user.phone }}
                onFinish={editInfo}
              >
                <ProFormText name="nickname" label="昵称" />
                <ProFormText
                  name="email"
                  label="邮箱"
                  rules={[{ type: 'email', message: '邮箱格式不正确' }]}
                />
                <ProFormText
                  name="phone"
                  label="手机号"
                  rules={[
                    { required: true, message: '请输入手机号' },
                    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' },
                  ]}
                />
              </ModalForm>
            </div>
          </ProCard>
          <ProCard colSpan={16}>
            <ProDescriptions
              title="基本信息"
              column={2}
              dataSource={user}
              columns={[
                { title: '用户名', dataIndex: 'username' },
                { title: '昵称', dataIndex: 'nickname' },
                { title: '部门', dataIndex: 'dept' },
                { title: '角色', dataIndex: 'role' },
                { title: '邮箱', dataIndex: 'email' },
                { title: '手机', dataIndex: 'phone' },
                { title: '创建时间', dataIndex: 'created_at', span: 2 },
              ]}
            />
          </ProCard>
        </ProCard>
        <ProCard title="安全设置" style={{ marginTop: 16 }}>
          <ModalForm
            title="修改密码"
            trigger={<Button type="primary">修改密码</Button>}
            modalProps={{ destroyOnHidden: true }}
            onFinish={changePwd}
          >
            <ProFormText.Password
              name="oldPassword"
              label="原密码"
              rules={[{ required: true, message: '请输入原密码' }]}
            />
            <ProFormText.Password
              name="newPassword"
              label="新密码"
              rules={[
                { required: true, message: '请输入新密码' },
                { min: 6, message: '至少 6 位' },
              ]}
            />
            <ProFormText.Password
              name="confirm"
              label="确认新密码"
              rules={[{ required: true, message: '请再次输入新密码' }]}
            />
          </ModalForm>
        </ProCard>
      </AdminPageContainer>
    </AdminLayout>
  )
}

export default ProfilePage
