# frozen_string_literal: true
ActiveAdmin.register LiquidLayout do
  actions :all, except: [:new, :edit]

  index pagination_total: false
  config.per_page = 20
  scope :active, show_count: false

  filter :title
  filter :content
  filter :experimental
  filter :primary_layout
  filter :post_action_layout

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for liquid_layout do
      row :versions do
        render '/versions/versions_link', model: liquid_layout, model_name: 'liquid_layout'
      end
    end
  end
end
