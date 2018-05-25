# frozen_string_literal: true

ActiveAdmin.register PendingAction do
  actions :all

  index pagination_total: false
  config.per_page = 20

  filter :page_id
end
