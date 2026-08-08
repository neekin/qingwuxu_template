import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormTextArea, ProFormDigit, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type DictionaryType = {
  id: number
  code: string
  name: string
  status: 'enabled' | 'disabled'
  remark: string | null
  sort: number
  created_at: string
}

const columns: ProColumns<DictionaryType>[] = [
  { title: '类型编码', dataIndex: 'code', search: true },
  { title: '类型名称', dataIndex: 'name', search: true },
  { title: '排序', dataIndex: 'sort', search: false },
  {
    title: '状态',
    dataIndex: 'status',
    search: false,
    render: (_, r) => (
      <Tag color={r.status === 'enabled' ? 'success' : 'error'}>{r.status === 'enabled' ? '启用' : '禁用'}</Tag>
    ),
  },
  {
    title: '备注',
    dataIndex: 'remark',
    ellipsis: true,
    search: false,
    render: (_, r) => (r.remark ? <Tag color="blue">{r.remark}</Tag> : <Tag>—</Tag>),
  },
  { title: '创建时间', dataIndex: 'created_at' },
]

const formItems = (
  <>
    <ProFormText name="code" label="类型编码" rules={[{ required: true, message: '请输入类型编码' }]} />
    <ProFormText name="name" label="类型名称" rules={[{ required: true, message: '请输入类型名称' }]} />
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

export default function DictionaryTypesPage() {
  const page = usePage()
  const dictionary_types = (page.props as Record<string, unknown>).dictionary_types as DictionaryType[]
  return (
    <AdminLayout>
      <Head title="字典类型管理" />
      <AdminPageContainer title="字典类型管理">
        <ProListPage<DictionaryType>
          rowKey="id"
          columns={columns}
          data={dictionary_types}
          formItems={formItems}
          apiBase="/admin/dictionary_types"
        />
      </AdminPageContainer>
    </AdminLayout>
  )
}
