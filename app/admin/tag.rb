# frozen_string_literal: true

ActiveAdmin.register Tag do
  permit_params :name, :actionkit_uri

  index do
    selectable_column
    id_column
    column :name
    column :actionkit_uri
    actions
  end

  filter :tags
  filter :name
  filter :actionkit_uri

  sidebar 'Previous Versions', only: :show do
    attributes_table_for tag do
      row :versions do
        render '/versions/versions_link', model: tag, model_name: 'tag'
      end
    end
  end
end
