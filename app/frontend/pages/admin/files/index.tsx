import { Head, usePage, router } from '@inertiajs/react'
import { App, Button, Card, Table, Tag, Upload, Popconfirm, Space } from 'antd'
import { UploadOutlined, DownloadOutlined, DeleteOutlined, FileOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import AdminLayout from '../../../layouts/AdminLayout'
import AdminPageContainer from '../../../components/AdminPageContainer'

type UploadedFile = {
  id: number
  filename: string
  content_type: string
  byte_size: number
  created_at: string
  preview_url: string
  download_url: string
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`
}

// 图片类型支持浏览器内预览，其余类型直接下载。
function isPreviewable(contentType: string): boolean {
  return contentType.startsWith('image/')
}

export default function FilesPage() {
  const { props } = usePage<{ files: UploadedFile[] }>()
  const files = props.files || []

  // antd v6：用 App.useApp() 取 message，避免静态方法无法消费主题 context 的告警。
  const { message } = App.useApp()

  const handleDelete = (id: number) => {
    router.delete(`/admin/files/${id}`, {
      onSuccess: () => message.success('删除成功'),
      onError: () => message.error('删除失败'),
    })
  }

  // 上传走 Inertia router.post（自动带 CSRF）；文件对象由 Inertia 自动转 FormData。
  const uploadProps = {
    multiple: true,
    showUploadList: false,
    customRequest: (options: any) => {
      router.post(
        '/admin/files',
        { file: options.file },
        {
          forceFormData: true,
          preserveScroll: true,
          onSuccess: () => {
            message.success('上传成功')
            options.onSuccess({})
          },
          onError: () => {
            message.error('上传失败，文件可能过大或为空')
            options.onError({})
          },
        }
      )
    },
  }

  const columns: ColumnsType<UploadedFile> = [
    {
      title: '文件名',
      dataIndex: 'filename',
      render: (v: string) => (
        <Space>
          <FileOutlined />
          <span>{v}</span>
        </Space>
      ),
    },
    { title: '类型', dataIndex: 'content_type', render: (v: string) => <Tag>{v}</Tag> },
    { title: '大小', dataIndex: 'byte_size', render: (v: number) => formatSize(v) },
    { title: '上传时间', dataIndex: 'created_at' },
    {
      title: '操作',
      key: 'action',
      render: (_, r) => (
        <Space>
          {isPreviewable(r.content_type) && (
            <a href={r.preview_url} target="_blank" rel="noreferrer">
              预览
            </a>
          )}
          <a href={r.download_url}>
            <DownloadOutlined /> 下载
          </a>
          <Popconfirm title="确认删除该文件?" onConfirm={() => handleDelete(r.id)}>
            <a style={{ color: '#cf1322' }}>
              <DeleteOutlined /> 删除
            </a>
          </Popconfirm>
        </Space>
      ),
    },
  ]

  return (
    <AdminLayout>
      <Head title="文件管理" />
      <AdminPageContainer
        title="文件管理"
        extra={
          <Upload {...uploadProps}>
            <Button type="primary" icon={<UploadOutlined />}>
              上传文件
            </Button>
          </Upload>
        }
      >
        <Card>
          <Table rowKey="id" columns={columns} dataSource={files} pagination={{ pageSize: 10 }} />
        </Card>
      </AdminPageContainer>
    </AdminLayout>
  )
}
