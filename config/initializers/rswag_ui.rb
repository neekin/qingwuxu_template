# frozen_string_literal: true

# RSwag UI：在 /api-docs 渲染 Swagger UI，拉取 RSwag::Api 伺服的规范。
Rswag::Ui.configure do |c|
  c.openapi_endpoint "/api-docs/v1/openapi.json", "青乌序后台 API V1"
end
