# frozen_string_literal: true
ActiveAdmin.register Link do
  permit_params :url, :title, :date, :source, :link_id

  sidebar 'Previous Versions', only: :show do
    attributes_table_for link do
      row :versions do
        render '/versions/versions_link', model: link, model_name: 'link'
      end
    end
  end
end
