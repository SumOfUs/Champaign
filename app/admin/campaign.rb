# frozen_string_literal: true

ActiveAdmin.register Campaign do
  permit_params :name, :active

  index do
    selectable_column
    id_column
    column :name
    column :active
    actions
  end

  filter :name
  filter :active

  sidebar 'Previous Versions', only: :show do
    attributes_table_for campaign do
      row :versions do
        render '/versions/versions_link', model: campaign, model_name: 'campaign'
      end
    end
  end
end
