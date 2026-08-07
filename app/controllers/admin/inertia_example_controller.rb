# frozen_string_literal: true
module Admin
  # 收归 Admin::BaseController：继承 require_login，杜绝公开访问，符合「Admin 控制器必须鉴权」红线。
  class InertiaExampleController < BaseController
    def index
      authorize! nil, to: :view?, with: InertiaExamplePolicy
      render inertia: {
        rails_version: Rails.version,
        ruby_version: RUBY_DESCRIPTION,
        rack_version: Rack.release,
        inertia_rails_version: InertiaRails::VERSION,
      }
    end
  end
end