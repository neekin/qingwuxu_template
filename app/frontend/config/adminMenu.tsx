import type { ReactNode } from 'react'
import {
  DashboardOutlined,
  UserOutlined,
  TeamOutlined,
  MenuOutlined,
  ApartmentOutlined,
  FileTextOutlined,
  FolderOpenOutlined,
  HistoryOutlined,
  IdcardOutlined,
  ExperimentOutlined,
  ScheduleOutlined,
  BookOutlined,
  UnorderedListOutlined,
  LogoutOutlined,
} from '@ant-design/icons'

/**
 * 后台菜单配置（单一配置源）
 * --------------------------------------------------------------------------
 * 本期「先不管验权」：每个菜单项带 `permission` 占位字段（对标若依权限字符），
 * 但**不做任何过滤/隐藏**——全部显示。未来服务端下发动态菜单时，直接替换本数组即可，
 * 前端按 `permission` 控制显隐（visible prop）的逻辑届时再接入，结构零返工。
 */
export type AdminMenuItem = {
  key: string
  label: string
  icon?: ReactNode
  /** 路由路径；父级菜单（含 children）可不填 */
  path?: string
  /** 权限字符占位，本期不消费 */
  permission?: string
  children?: AdminMenuItem[]
}

export const adminMenu: AdminMenuItem[] = [
  {
    key: 'dashboard',
    label: '仪表盘',
    icon: <DashboardOutlined />,
    path: '/admin',
    permission: 'dashboard:view',
  },
  {
    key: 'system',
    label: '系统管理',
    icon: <UserOutlined />,
    permission: 'system:manage',
    children: [
      { key: 'users', label: '用户管理', icon: <UserOutlined />, path: '/admin/users', permission: 'system:user:list' },
      { key: 'roles', label: '角色管理', icon: <TeamOutlined />, path: '/admin/roles', permission: 'system:role:list' },
      { key: 'menus', label: '菜单管理', icon: <MenuOutlined />, path: '/admin/menus', permission: 'system:menu:list' },
      { key: 'departments', label: '部门管理', icon: <ApartmentOutlined />, path: '/admin/departments', permission: 'system:dept:list' },
      { key: 'files', label: '文件管理', icon: <FolderOpenOutlined />, path: '/admin/files', permission: 'system:file:list' },
      {
        key: 'dict',
        label: '字典管理',
        icon: <BookOutlined />,
        permission: 'system:dict:type:list',
        children: [
          { key: 'dict-types', label: '类型管理', icon: <BookOutlined />, path: '/admin/dictionary_types', permission: 'system:dict:type:list' },
          { key: 'dict-data', label: '数据项管理', icon: <UnorderedListOutlined />, path: '/admin/dictionary_data', permission: 'system:dict:data:list' },
        ],
      },
    ],
  },
  {
    key: 'monitor',
    label: '系统监控',
    icon: <FileTextOutlined />,
    permission: 'monitor:manage',
    children: [
      { key: 'operation-logs', label: '操作日志', icon: <FileTextOutlined />, path: '/admin/operation-logs', permission: 'monitor:operlog:list' },
      { key: 'login-logs', label: '登录日志', icon: <HistoryOutlined />, path: '/admin/login-logs', permission: 'monitor:loginlog:list' },
      { key: 'solid-queue-jobs', label: '定时任务', icon: <ScheduleOutlined />, path: '/admin/solid_queue_jobs', permission: 'monitor:job:list' },
      { key: 'system-monitor', label: '服务监控', icon: <DashboardOutlined />, path: '/admin/system_monitor', permission: 'monitor:server:view' },
      { key: 'online-users', label: '在线用户', icon: <LogoutOutlined />, path: '/admin/online_users', permission: 'system:online:list' },
    ],
  },
  {
    key: 'profile',
    label: '个人中心',
    icon: <IdcardOutlined />,
    path: '/admin/profile',
    permission: 'user:profile:view',
  },
  {
    key: 'inertia-example',
    label: 'Inertia 演示',
    icon: <ExperimentOutlined />,
    path: '/admin/inertia-example',
  },
]

export default adminMenu
