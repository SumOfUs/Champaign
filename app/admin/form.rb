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
        link_to "There are #{form.versions.length} total versions of this form. Click here to view.", controller: '/versions', action: 'show', model: 'form', id: form.id
      end
    end
  end
end
