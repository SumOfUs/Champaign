# frozen_string_literal: true
ActiveAdmin.register PagesTag do
  permit_params :page_id, :tag_id

  config.per_page = 20
  index pagination_total: false

  index do
    selectable_column
    id_column
    column :page
    column :tag
    actions
  end
end
