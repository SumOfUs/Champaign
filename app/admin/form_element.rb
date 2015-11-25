ActiveAdmin.register FormElement do
  permit_params :label, :data_type, :field_type, :default_value, :required, :visible, :name, :position

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
        link_to "There are #{form_element.versions.length} total versions of this form_element. Click here to view.", controller: '/versions', action: 'show', model: 'form_element', id: form_element.id
      end
    end
  end
end
