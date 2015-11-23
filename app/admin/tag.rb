ActiveAdmin.register Tag do
  permit_params :name, :actionkit_uri

  index do
    selectable_column
    id_column
    column :name
    column :actionkit_uri
    actions
  end

  filter :pages
  filter :name
  filter :actionkit_uri
end
