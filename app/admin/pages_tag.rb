# frozen_string_literal: true
ActiveAdmin.register PagesTag do
  permit_params :page_id, :tag_id

  index do
    selectable_column
    id_column
    column :page
    column :tag
    actions
  end
end
