ActiveAdmin.register Member do
  permit_params :email, :country, :full_name, :city, :postal, :title, :address1, :address2, :actionkit_member_id
  actions :all, except: [:destroy]

  sidebar 'Previous Versions', only: :show do
    attributes_table_for member do
      row :versions do
        render '/versions/versions_link', model: member, model_name: 'member'
      end
    end
  end
end
