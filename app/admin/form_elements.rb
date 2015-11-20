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
end
