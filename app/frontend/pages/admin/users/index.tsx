import { Head } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type User = {
  id: number
  username: string
  nickname: string
  dept: string
  role: string
  email: string
  status: 'enabled' | 'disabled'
  created_at: string
}

const mockData: User[] = [
  { id: 1, username: 'admin', nickname: '超级管理员', dept: '研发部', role: '超级管理员', email: 'admin@qingwuxu.cn', status: 'enabled', created_at: '2026-01-02 10:00' },
  { id: 2, username: 'wangwu', nickname: '王五', dept: '研发部', role: '管理员', email: 'wangwu@qingwuxu.cn', status: 'enabled', created_at: '2026-02-11 14:22' },
  { id: 3, username: 'lisi', nickname: '李四', dept: '市场部', role: '普通用户', email: 'lisi@qingwuxu.cn', status: 'enabled', created_at: '2026-02-18 09:31' },
  { id: 4, username: 'zhaoliu', nickname: '赵六', dept: '财务部', role: '普通用户', email: 'zhaoliu@qingwuxu.cn', status: 'disabled', created_at: '2026-03-05 16:48' },
  { id: 5, username: 'qianqi', nickname: '钱七', dept: '人事部', role: '管理员', email: 'qianqi@qingwuxu.cn', status: 'enabled', created_at: '2026-03-22 11:05' },
  { id: 6, username: 'sunba', nickname: '孙八', dept: '研发部', role: '普通用户', email: 'sunba@qingwuxu.cn', status: 'enabled', created_at: '2026-04-01 08:15' },
  { id: 7, username: 'zhoujiu', nickname: '周九', dept: '市场部', role: '普通用户', email: 'zhoujiu@qingwuxu.cn', status: 'disabled', created_at: '2026-04-09 13:40' },
  { id: 8, username: 'wushi', nickname: '吴十', dept: '财务部', role: '普通用户', email: 'wushi@qingwuxu.cn', status: 'enabled', created_at: '2026-04-17 17:02' },
  { id: 9, username: 'zhengyi', nickname: '郑一', dept: '研发部', role: '管理员', email: 'zhengyi@qingwuxu.cn', status: 'enabled', created_at: '2026-05-02 10:33' },
  { id: 10, username: 'fanger', nickname: '方二', dept: '人事部', role: '普通用户', email: 'fanger@qingwuxu.cn', status: 'enabled', created_at: '2026-05-19 15:21' },
  { id: 11, username: 'liusan', nickname: '刘三', dept: '市场部', role: '普通用户', email: 'liusan@qingwuxu.cn', status: 'enabled', created_at: '2026-06-03 09:09' },
  { id: 12, username: 'chenqi', nickname: '陈七', dept: '研发部', role: '普通用户', email: 'chenqi@qingwuxu.cn', status: 'disabled', created_at: '2026-06-21 12:55' },
  { id: 13, username: 'yangba', nickname: '杨八', dept: '财务部', role: '管理员', email: 'yangba@qingwuxu.cn', status: 'enabled', created_at: '2026-07-08 18:30' },
  { id: 14, username: 'huangjiu', nickname: '黄九', dept: '人事部', role: '普通用户', email: 'huangjiu@qingwuxu.cn', status: 'enabled', created_at: '2026-07-25 08:47' },
  { id: 15, username: 'xushi', nickname: '徐十', dept: '研发部', role: '普通用户', email: 'xushi@qingwuxu.cn', status: 'enabled', created_at: '2026-08-01 20:11' },
]

const columns: ProColumns<User>[] = [
  { title: '用户名', dataIndex: 'username', search: true },
  { title: '昵称', dataIndex: 'nickname', search: true },
  { title: '部门', dataIndex: 'dept' },
  { title: '角色', dataIndex: 'role' },
  { title: '邮箱', dataIndex: 'email' },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => (
      <Tag color={r.status === 'enabled' ? 'success' : 'error'}>{r.status === 'enabled' ? '启用' : '禁用'}</Tag>
    ),
  },
  { title: '创建时间', dataIndex: 'created_at' },
]

const formItems = (
  <>
    <ProFormText name="username" label="用户名" rules={[{ required: true, message: '请输入用户名' }]} />
    <ProFormText name="nickname" label="昵称" />
    <ProFormText name="email" label="邮箱" rules={[{ type: 'email', message: '邮箱格式不正确' }]} />
    <ProFormSelect
      name="dept"
      label="部门"
      options={[
        { value: '研发部', label: '研发部' },
        { value: '市场部', label: '市场部' },
        { value: '财务部', label: '财务部' },
        { value: '人事部', label: '人事部' },
      ]}
    />
    <ProFormSelect
      name="role"
      label="角色"
      options={[
        { value: '超级管理员', label: '超级管理员' },
        { value: '管理员', label: '管理员' },
        { value: '普通用户', label: '普通用户' },
      ]}
    />
    <ProFormSelect
      name="status"
      label="状态"
      initialValue="enabled"
      options={[
        { value: 'enabled', label: '启用' },
        { value: 'disabled', label: '禁用' },
      ]}
    />
  </>
)

export default function UsersPage() {
  return (
    <AdminLayout>
      <Head title="用户管理" />
      <AdminPageContainer title="用户管理">
        <ProListPage<User> rowKey="id" columns={columns} mockData={mockData} formItems={formItems} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
