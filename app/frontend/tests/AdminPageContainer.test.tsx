import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import AdminPageContainer from '../components/AdminPageContainer'

describe('AdminPageContainer', () => {
  it('渲染标题与子内容（验证 antd/pro-components 在 jsdom 管线可用）', () => {
    render(
      <AdminPageContainer title="测试标题">
        <div>子内容</div>
      </AdminPageContainer>,
    )

    expect(screen.getByText('测试标题')).toBeInTheDocument()
    expect(screen.getByText('子内容')).toBeInTheDocument()
  })

  it('渲染 extra 操作区', () => {
    render(
      <AdminPageContainer title="标题" extra={<button type="button">新增</button>}>
        <div>内容</div>
      </AdminPageContainer>,
    )

    expect(screen.getByText('新增')).toBeInTheDocument()
  })
})
