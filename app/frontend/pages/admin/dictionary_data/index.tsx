import { Head, usePage } from '@inertiajs/react'
import { Tag } from 'antd'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'
import ProListPage from '../../../components/ProListPage'
import { ProFormText, ProFormDigit, ProFormSelect } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'

type DictionaryData = {
  id: number
  dict_type: string
  label: string
  value: string
  sort: number
  status: 'enabled' | 'disabled'
  remark: string | null
  created_at: string
}

const columns: ProColumns<DictionaryData>[] = [
  { title: '所属类型', dataIndex: 'dict_type', search: true },
  { title: '数据标签', dataIndex: 'label', search: true },
  { title: '数据键值', dataIndex: 'value' },
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

const buildFormItems = (dictType?: string) => (
  <>
    <ProFormText name="dict_type" label="所属类型编码" initialValue={dictType} rules={[{ required: true, message: '请输入所属类型编码' }]} />
    <ProFormText name="label" label="数据标签" rules={[{ required: true, message: '请输入数据标签' }]} />
    <ProFormText name="value" label="数据键值" rules={[{ required: true, message: '请输入数据键值' }]} />
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
    <ProFormText name="remark" label="备注" />
  </>
)

export default function DictionaryDataPage() {
  const page = usePage()
  const props = page.props as Record<string, unknown>
  const dictionary_data = props.dictionary_data as DictionaryData[]
  const dict_type = props.dict_type as string | undefined
  return (
    <AdminLayout>
      <Head title="字典数据项管理" />
      <AdminPageContainer title="字典数据项管理">
        <ProListPage<DictionaryData>
          rowKey="id"
          columns={columns}
          data={dictionary_data}
          formItems={buildFormItems(dict_type)}
          apiBase="/admin/dictionary_data"
        />
      </AdminPageContainer>
    </AdminLayout>
  )
}
