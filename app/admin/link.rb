# frozen_string_literal: true
ActiveAdmin.register Link do
  permit_params :url, :title, :date, :source, :link_id

  index pagination_total: false
  config.per_page = 20
  scope :active, show_count: false

  filter :page_title_cont, label: 'Page'
  filter :url
  filter :title
  filter :source

  sidebar 'Previous Versions', only: :show do
    attributes_table_for link do
      row :versions do
        render '/versions/versions_link', model: link, model_name: 'link'
      end
    end
  end
end
