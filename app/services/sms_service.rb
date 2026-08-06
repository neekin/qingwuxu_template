# frozen_string_literal: true

# 短信网关抽象层。
# 开发期用 MockSmsGateway：仅打日志、不真实发送，验证码在 server 日志可见，方便本地联调。
# 真实接入：实现 AliyunSmsGateway / TencentSmsGateway，读取
# Rails.application.credentials.sms_provider 后在 #gateway 切换即可，无需改调用方。
class SmsService
  class << self
    def send_code(receiver:, code:, purpose:)
      gateway.send_code(receiver: receiver, code: code, purpose: purpose)
    end

    private

    def gateway
      # TODO(接入真实短信): 按 credentials 选择 AliyunSmsGateway / TencentSmsGateway
      MockSmsGateway
    end
  end

  # 开发期实现：把验证码打到 Rails 日志，不触碰任何短信服务商。
  class MockSmsGateway
    def self.send_code(receiver:, code:, purpose:)
      Rails.logger.info(
        "[MockSMS] 向 #{receiver} 发送验证码(#{purpose}): #{code}（开发期不真实发送）"
      )
      true
    end
  end
end
