# frozen_string_literal: true

ActiveAdmin.register Page do
  actions :all, except: %i[new destroy]
  permit_params :publish_status, :featured

  config.per_page = 20
  scope :publish_status, show_count: false

  filter :liquid_layout, label: 'Layout'
  filter :language
  filter :follow_up_page_title_cont, label: 'Follow up page title'
  filter :follow_up_liquid_layout, label: 'Follow up layout'
  filter :title
  filter :slug
  filter :publish_status
  filter :featured

  index pagination_total: false do
    selectable_column
    id_column
    column :title
    column :featured
    column :publish_status
    column :status
    actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for page do
      row :versions do
        render '/versions/versions_link', model: page, model_name: 'page'
      end
    end
  end
end
