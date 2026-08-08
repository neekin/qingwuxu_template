import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormTextArea, ProFormDigit, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type Department = {
  id: number
  code: string
  name: string
  parent_id: number | null
  parent_name: string | null
  leader: string | null
  sort: number
  status: 'enabled' | 'disabled'
  remark: string | null
  created_at: string
}

// 计算某节点的全部子孙 id（基于平铺列表），用于上级下拉排除自身及后代防环。
function descendantIds(list: Department[], rootId: number): Set<number> {
  const childrenOf = new Map<number | null, Department[]>()
  list.forEach((d) => {
    const arr = childrenOf.get(d.parent_id) || []
    arr.push(d)
    childrenOf.set(d.parent_id, arr)
  })
  const result = new Set<number>()
  const stack = [rootId]
  while (stack.length) {
    const cur = stack.pop() as number
    ;(childrenOf.get(cur) || []).forEach((c) => {
      if (!result.has(c.id)) {
        result.add(c.id)
        stack.push(c.id)
      }
    })
  }
  return result
}

const columns: ProColumns<Department>[] = [
  { title: '部门编码', dataIndex: 'code', search: true },
  { title: '部门名称', dataIndex: 'name', search: true },
  {
    title: '上级部门',
    dataIndex: 'parent_name',
    search: false,
    render: (_, r) => (r.parent_name ? <Tag color="blue">{r.parent_name}</Tag> : <Tag>—</Tag>),
  },
  { title: '负责人', dataIndex: 'leader', search: false },
  { title: '排序', dataIndex: 'sort', search: false },
  {
    title: '状态',
    dataIndex: 'status',
    search: false,
    render: (_, r) => (
      <Tag color={r.status === 'enabled' ? 'success' : 'error'}>{r.status === 'enabled' ? '启用' : '禁用'}</Tag>
    ),
  },
  { title: '创建时间', dataIndex: 'created_at' },
]

export default function DepartmentsPage() {
  const page = usePage()
  const departments = (page.props as Record<string, unknown>).departments as Department[]

  // 上级部门下拉：排除自身及全部后代，避免形成环。
  const parentOptions = (record?: Department) => {
    const blocked = record ? new Set<number>([record.id, ...descendantIds(departments, record.id)]) : new Set<number>()
    return departments
      .filter((d) => !blocked.has(d.id))
      .map((d) => ({ value: d.id, label: d.name }))
  }

  const formItems = (record?: Department) => (
    <>
      <ProFormText name="code" label="部门编码" rules={[{ required: true, message: '请输入部门编码' }]} />
      <ProFormText name="name" label="部门名称" rules={[{ required: true, message: '请输入部门名称' }]} />
      <ProFormSelect
        name="parent_id"
        label="上级部门"
        rules={[{ required: false }]}
        options={parentOptions(record)}
        fieldProps={{ allowClear: true }}
      />
      <ProFormText name="leader" label="负责人" />
      <ProFormDigit name="sort" label="排序" initialValue={0} />
      <ProFormSelect
        name="status"
        label="状态"
        initialValue="enabled"
        options={[
          { value: 'enabled', label: '启用' },
          { value: 'disabled', label: '禁用' },
        ]}
      />
      <ProFormTextArea name="remark" label="备注" />
    </>
  )

  return (
    <AdminLayout>
      <Head title="部门管理" />
      <AdminPageContainer title="部门管理">
        <ProListPage<Department>
          rowKey="id"
          columns={columns}
          data={departments}
          formItemsFor={formItems}
          apiBase="/admin/departments"
        />
      </AdminPageContainer>
    </AdminLayout>
  )
}
