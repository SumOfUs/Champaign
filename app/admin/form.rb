# frozen_string_literal: true

ActiveAdmin.register Form do
  permit_params :name, :description, :visible, :master

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :visible
    column :master
    actions
  end

  filter :name
  filter :description
  filter :visible
  filter :master

  sidebar 'Previous Versions', only: :show do
    attributes_table_for form do
      row :versions do
        render '/versions/versions_link', model: form, model_name: 'form'
      end
    end
  end
end
