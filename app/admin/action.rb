# frozen_string_literal: true

ActiveAdmin.register Action do
  actions :all, except: %i[new edit]

  index pagination_total: false
  config.per_page = 20
  scope :active, show_count: false

  filter :page_title_cont, label: 'Page'
  filter :subscribed_member
  filter :donation
  filter :created_at

  sidebar 'Previous Versions', only: :show do
    attributes_table_for action do
      row :versions do
        render '/versions/versions_link', model: action, model_name: 'action'
      end
    end
  end
end
