# frozen_string_literal: true
ActiveAdmin.register Image do
  actions :all, except: [:new, :edit, :destroy]

  index pagination_total: false
  config.per_page = 20
  scope :active, show_count: false

  filter :page_title_cont, label: 'Page'
  filter :content_file_name
  filter :content_content_type
  filter :content_file_size

  sidebar 'Previous Versions', only: :show do
    attributes_table_for image do
      row :versions do
        render '/versions/versions_link', model: image, model_name: 'image'
      end
    end
  end
end
