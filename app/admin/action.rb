# frozen_string_literal: true
ActiveAdmin.register Action do
  actions :all, except: [:new, :edit]

  index pagination_total: false
  config.per_page = 20

  sidebar 'Previous Versions', only: :show do
    attributes_table_for action do
      row :versions do
        render '/versions/versions_link', model: action, model_name: 'action'
      end
    end
  end
end
