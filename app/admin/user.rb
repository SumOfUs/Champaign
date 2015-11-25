ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs 'Admin Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for user do
      row :versions do
        link_to "There are #{user.versions.length} total versions of this user. Click here to view.", controller: '/versions', action: 'show', model: 'user', id: user.id
      end
    end
  end
end
