# frozen_string_literal: true

# RSwag API：从 swagger/ 目录伺服 OpenAPI 规范（JSON/YAML）。
# 配合 RSwag::Ui 在 /api-docs 提供交互式文档。规范手维护（见 swagger/v1/openapi.json）。
Rswag::Api.configure do |c|
  c.openapi_root = Rails.root.join("swagger").to_s
end
