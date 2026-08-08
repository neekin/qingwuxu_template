import { useState } from 'react'
import { ProTable, ModalForm } from '@ant-design/pro-components'
import type { ProColumns } from '@ant-design/pro-components'
import { Button, Popconfirm, message } from 'antd'
import { router } from '@inertiajs/react'
import type { ReactNode } from 'react'

type ProListPageProps<T> = {
  /** 行主键：字段名或函数 */
  rowKey: string | ((record: T) => string)
  columns: ProColumns<T>[]
  /** 真实数据（由后端 Inertia props 传入）；与 mockData 二选一 */
  data?: T[]
  /** 前端 mock 数据（仅无后端接口的页面使用，逐步废弃） */
  mockData?: T[]
  /** 是否显示搜索栏，默认 true */
  search?: boolean
  /** 是否可编辑（新建/编辑/删除），默认 true；日志等只读页传 false */
  editable?: boolean
  /** 新建/编辑弹窗内的表单字段（由调用页用 ProForm 字段提供） */
  formItems?: ReactNode
  /**
   * 写路径 API 基址（如 "/admin/dictionary_types"）。传入即启用服务端模式：
   * - 新建 → router.post(apiBase, values)
   * - 编辑 → router.put(`${apiBase}/${id}`, values)
   * - 删除 → router.delete(`${apiBase}/${id}`)
   * 后端成功返回 redirect → Inertia 自动刷新列表（data 由服务端重新注入）。
   * 留空则退回原前端本地 mock 增删改（仅遗留只读页使用）。
   */
  apiBase?: string
}

function keyOf<T>(record: T, rowKey: string | ((r: T) => string)): string {
  if (typeof rowKey === 'function') return rowKey(record)
  return String((record as Record<string, unknown>)[rowKey])
}

/**
 * 可复用列表页模板。
 * - 真实数据：传 `data`（后端 Inertia props），由服务端查询后注入。
 * - 兜底：未接后端的页面仍可传 `mockData` 本地渲染（后续分期替换）。
 * 业务字段（列/数据/表单）由调用页通过 props 注入，本组件不写任何业务硬编码。
 * 当前为客户端分页/搜索（ProTable 内置）；服务端分页为后续分期增强项。
 */
export default function ProListPage<T>({
  rowKey,
  columns,
  data,
  mockData,
  search = true,
  editable = true,
  formItems,
  apiBase,
}: ProListPageProps<T>) {
  const [list, setList] = useState<T[]>(data ?? mockData ?? [])
  const [editing, setEditing] = useState<T | null>(null)
  const [open, setOpen] = useState(false)

  // 服务端模式：删除走真实 DELETE；否则退回本地过滤（遗留只读/无后端页）。
  const handleDelete = (k: string) => {
    if (apiBase) {
      router.delete(`${apiBase}/${k}`)
    } else {
      setList((prev) => prev.filter((r) => keyOf(r, rowKey) !== k))
    }
  }

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
        dataSource={list as any}
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
        onFinish={(values: Record<string, unknown>) =>
          new Promise<boolean>((resolve) => {
            // 服务端模式：新建 POST / 编辑 PUT，失败保持弹窗打开以展示错误。
            if (apiBase) {
              const id = keyOf(editing as T, rowKey)
              const url = editing ? `${apiBase}/${id}` : apiBase
              const submit = editing ? router.put : router.post
              submit(url, values as any, {
                onSuccess: () => { setOpen(false); resolve(true) },
                onError: () => { message.error('提交失败，请检查表单'); resolve(false) },
              })
            } else {
              // 遗留本地 mock 模式（无后端写接口）
              if (editing) {
                const k = keyOf(editing, rowKey)
                setList((prev) => prev.map((r) => (keyOf(r, rowKey) === k ? { ...r, ...values } : r)))
              } else {
                const id = String(Date.now())
                const newRecord = (typeof rowKey === 'function' ? { ...values } : { ...values, [rowKey]: id }) as T
                setList((prev) => [newRecord, ...prev])
              }
              resolve(true)
            }
          })
        }
      >
        {formItems}
      </ModalForm>
    </>
  )
}
