import { useState } from 'react'
import { ProTable, ModalForm } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'
import { Button, Popconfirm } from 'antd'
import type { ReactNode } from 'react'

type ProListPageProps<T> = {
  /** 行主键：字段名或函数 */
  rowKey: string | ((record: T) => string)
  columns: ProColumns<T>[]
  /** 前端 mock 数据 */
  mockData: T[]
  /** 是否显示搜索栏，默认 true */
  search?: boolean
  /** 是否可编辑（新建/编辑/删除），默认 true；日志等只读页传 false */
  editable?: boolean
  /** 新建/编辑弹窗内的表单字段（由调用页用 ProForm 字段提供） */
  formItems?: ReactNode
}

function keyOf<T>(record: T, rowKey: string | ((r: T) => string)): string {
  if (typeof rowKey === 'function') return rowKey(record)
  return String((record as Record<string, unknown>)[rowKey])
}

/**
 * 可复用列表页模板（本期 mock 数据，本地 state CRUD）。
 * 业务字段（列/数据/表单）由调用页通过 props 注入，本组件不写任何业务硬编码。
 * 未来接真实数据时，只需把 dataSource 换成 request 异步拉取即可。
 */
export default function ProListPage<T>({
  rowKey,
  columns,
  mockData,
  search = true,
  editable = true,
  formItems,
}: ProListPageProps<T>) {
  const [data, setData] = useState<T[]>(mockData)
  const [editing, setEditing] = useState<T | null>(null)
  const [open, setOpen] = useState(false)

  const handleDelete = (k: string) => setData((prev) => prev.filter((r) => keyOf(r, rowKey) !== k))

  const actionColumn: ProColumns<T> | null = editable
    ? {
        title: '操作',
        valueType: 'option',
        key: 'option',
        render: (_dom, record) => [
          <a key="edit" onClick={() => { setEditing(record); setOpen(true) }}>
            编辑
          </a>,
          <Popconfirm
            key="del"
            title="确认删除该记录?"
            onConfirm={() => handleDelete(keyOf(record, rowKey))}
          >
            <a>删除</a>
          </Popconfirm>,
        ],
      }
    : null

  return (
    <>
      <ProTable
        rowKey={rowKey as any}
        columns={(actionColumn ? [...columns, actionColumn] : columns) as ProColumns<any>[]}
        dataSource={data as any}
        search={search ? {} : false}
        pagination={{ pageSize: 10 }}
        toolBarRender={() =>
          editable
            ? [
                <Button key="add" type="primary" onClick={() => { setEditing(null); setOpen(true) }}>
                  新建
                </Button>,
              ]
            : []
        }
        options={{ reload: false, setting: false, density: false }}
      />
      <ModalForm
        title={editing ? '编辑' : '新建'}
        open={open}
        initialValues={editing || {}}
        onOpenChange={setOpen}
        modalProps={{ destroyOnClose: true }}
        onFinish={async (values: Record<string, unknown>) => {
          if (editing) {
            const k = keyOf(editing, rowKey)
            setData((prev) => prev.map((r) => (keyOf(r, rowKey) === k ? { ...r, ...values } : r)))
          } else {
            // 新增：用时间戳生成临时主键（若 rowKey 为字段名）
            const id = String(Date.now())
            const newRecord = (typeof rowKey === 'function' ? { ...values } : { ...values, [rowKey]: id }) as T
            setData((prev) => [newRecord, ...prev])
          }
          return true
        }}
      >
        {formItems}
      </ModalForm>
    </>
  )
}
