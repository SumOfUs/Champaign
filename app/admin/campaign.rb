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
end
