import { Head } from '@inertiajs/react'
import { Avatar, Button } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import { ProCard, ProDescriptions, ModalForm, ProFormText } from '@ant-design/pro-components'

const user = {
  username: 'admin',
  nickname: '超级管理员',
  dept: '研发部',
  role: '超级管理员',
  email: 'admin@qingwuxu.cn',
  phone: '138****8888',
  created_at: '2026-01-02 10:00',
}

export default function ProfilePage() {
  return (
    <AdminLayout>
      <Head title="个人中心" />
      <AdminPageContainer title="个人中心">
        <ProCard gutter={16} wrap>
          <ProCard colSpan={8}>
            <div style={{ textAlign: 'center' }}>
              <Avatar size={80} style={{ backgroundColor: '#1B6E78' }}>
                管
              </Avatar>
              <h2 style={{ margin: '12px 0 0' }}>{user.nickname}</h2>
              <p style={{ color: '#6E7E7E', margin: 0 }}>{user.role}</p>
              <ModalForm
                title="修改密码"
                trigger={
                  <Button type="primary" block style={{ marginTop: 16 }}>
                    修改密码
                  </Button>
                }
                modalProps={{ destroyOnHidden: true }}
                onFinish={async () => true}
              >
                <ProFormText.Password name="oldPassword" label="原密码" rules={[{ required: true, message: '请输入原密码' }]} />
                <ProFormText.Password name="newPassword" label="新密码" rules={[{ required: true, message: '请输入新密码' }]} />
                <ProFormText.Password name="confirm" label="确认新密码" rules={[{ required: true, message: '请再次输入新密码' }]} />
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
      </AdminPageContainer>
    </AdminLayout>
  )
}
