# frozen_string_literal: true

# 前台（C 端）落地页 —— 用于演示 Hotwire/Turbo 的三大特性：
#   · Turbo Drive  ：普通链接无整页刷新跳转
#   · Turbo Frames ：局部懒加载 / 局部更新
#   · Turbo Streams：服务端推送 DOM 变更（无需手写 JS）
class WelcomeController < ApplicationController
  def index
  end

  # 由首页的 <turbo-frame src> 懒加载，返回仅含 frame 的片段
  def clock
    @time = Time.current
  end

  # 接收留言表单提交，返回 turbo-stream 指令把新条目 append 到列表
  def messages
    @message = params[:message].to_s
    respond_to do |format|
      format.turbo_stream
    end
  end
end
