import type { ReactNode } from 'react'
import { PageContainer } from '@ant-design/pro-components'

type Props = {
  title: string
  extra?: ReactNode
  children: ReactNode
}

/** 统一页面容器：标题 + 操作区(extra) + 内容 padding，面包屑由 AdminLayout 处理 */
export default function AdminPageContainer({ title, extra, children }: Props) {
  return (
    <PageContainer title={title} extra={extra}>
      {children}
    </PageContainer>
  )
}
