# frozen_string_literal: true
ActiveAdmin.register Page do
  actions :all, except: [:new, :destroy]
  permit_params :active, :featured

  config.per_page = 20

  index pagination_total: false do
    selectable_column
    id_column
    column :title
    column :featured
    column :active
    column :status
    actions
  end

  form do |f|
    f.inputs 'Page Details - Edit the page in the page editor' do
      f.input :active
      f.input :featured
    end
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
