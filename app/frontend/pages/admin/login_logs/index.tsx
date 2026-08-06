import { Head } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import type { ProColumns } from '@ant-design/pro-components'

type LoginLog = {
  id: number
  username: string
  ip: string
  location: string
  browser: string
  os: string
  time: string
  status: 'success' | 'fail'
}

const mockData: LoginLog[] = [
  { id: 1, username: 'admin', ip: '192.168.1.10', location: '广东 深圳', browser: 'Chrome 120', os: 'macOS', time: '2026-08-06 09:12', status: 'success' },
  { id: 2, username: 'wangwu', ip: '192.168.1.21', location: '北京 海淀', browser: 'Edge 120', os: 'Windows 11', time: '2026-08-06 08:55', status: 'success' },
  { id: 3, username: 'lisi', ip: '192.168.1.31', location: '上海 浦东', browser: 'Chrome 119', os: 'Windows 10', time: '2026-08-06 08:40', status: 'success' },
  { id: 4, username: 'zhaoliu', ip: '192.168.1.45', location: '浙江 杭州', browser: 'Firefox 121', os: 'Ubuntu', time: '2026-08-05 22:10', status: 'fail' },
  { id: 5, username: 'qianqi', ip: '192.168.1.50', location: '四川 成都', browser: 'Chrome 120', os: 'macOS', time: '2026-08-05 19:33', status: 'success' },
  { id: 6, username: 'yangba', ip: '192.168.1.60', location: '广东 广州', browser: 'Safari 17', os: 'macOS', time: '2026-08-05 18:02', status: 'success' },
  { id: 7, username: 'admin', ip: '192.168.1.99', location: '未知', browser: 'curl/8.0', os: 'Linux', time: '2026-08-05 03:14', status: 'fail' },
  { id: 8, username: 'chenqi', ip: '192.168.1.80', location: '江苏 南京', browser: 'Chrome 118', os: 'Windows 11', time: '2026-08-04 21:45', status: 'success' },
  { id: 9, username: 'sunba', ip: '192.168.1.90', location: '湖北 武汉', browser: 'Chrome 120', os: 'Windows 10', time: '2026-08-04 09:30', status: 'success' },
  { id: 10, username: 'huangjiu', ip: '192.168.1.88', location: '福建 厦门', browser: 'Edge 120', os: 'Windows 11', time: '2026-08-03 17:20', status: 'success' },
  { id: 11, username: 'xushi', ip: '192.168.1.77', location: '陕西 西安', browser: 'Chrome 119', os: 'macOS', time: '2026-08-03 10:05', status: 'success' },
  { id: 12, username: 'fanger', ip: '192.168.1.66', location: '山东 青岛', browser: 'Firefox 121', os: 'Windows 10', time: '2026-08-02 14:50', status: 'fail' },
]

const columns: ProColumns<LoginLog>[] = [
  { title: '用户名', dataIndex: 'username', search: true },
  { title: '登录 IP', dataIndex: 'ip' },
  { title: '登录地点', dataIndex: 'location' },
  { title: '浏览器', dataIndex: 'browser' },
  { title: '操作系统', dataIndex: 'os' },
  { title: '登录时间', dataIndex: 'time' },
  {
    title: '状态',
    dataIndex: 'status',
    render: (_, r) => <Tag color={r.status === 'success' ? 'success' : 'error'}>{r.status === 'success' ? '成功' : '失败'}</Tag>,
  },
]

export default function LoginLogsPage() {
  return (
    <AdminLayout>
      <Head title="登录日志" />
      <AdminPageContainer title="登录日志">
        <ProListPage<LoginLog> rowKey="id" columns={columns} mockData={mockData} editable={false} />
      </AdminPageContainer>
    </AdminLayout>
  )
}
