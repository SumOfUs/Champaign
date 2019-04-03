# frozen_string_literal: true

ActiveAdmin.register Language do
  permit_params :code, :name
  config.filters = false

  sidebar 'Previous Versions', only: :show do
    attributes_table_for language do
      row :versions do
        render '/versions/versions_link', model: language, model_name: 'language'
      end
    end
  end
end
