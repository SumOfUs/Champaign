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
end
