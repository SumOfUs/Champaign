# frozen_string_literal: true

ActiveAdmin.register FormElement do
  permit_params :label, :data_type, :default_value, :required, :visible, :name, :position

  index do
    selectable_column
    id_column
    column :label
    column :name
    column :form
    column :data_type
    actions
  end

  filter :label
  filter :name
  filter :data_type
  filter :form

  sidebar 'Previous Versions', only: :show do
    attributes_table_for form_element do
      row :versions do
        render '/versions/versions_link', model: form_element, model_name: 'form_element'
      end
    end
  end
end
