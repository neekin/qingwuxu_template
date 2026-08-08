# frozen_string_literal: true

require "test_helper"

class LoginSessionTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: "ls_#{SecureRandom.hex(3)}",
      phone: "137#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
      password: "secret123"
    )
  end

  test "创建会话自动生成唯一 token 并关联用户" do
    s = LoginSession.create!(user: @user, last_seen_at: Time.current)
    assert s.token.present?
    assert_equal @user.id, s.user_id
  end

  test "online 作用域按最后访问阈值过滤" do
    online = LoginSession.create!(user: @user, last_seen_at: 1.minute.ago)
    offline = LoginSession.create!(user: @user, last_seen_at: 2.hours.ago)
    ids = LoginSession.online.pluck(:id)
    assert_includes ids, online.id
    assert_not_includes ids, offline.id
  end

  test "touch_last_seen 更新最后访问时间" do
    s = LoginSession.create!(user: @user, last_seen_at: 2.hours.ago)
    s.touch_last_seen
    assert_in_delta Time.current.to_i, s.reload.last_seen_at.to_i, 2
  end
end
