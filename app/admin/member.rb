ActiveAdmin.register Member do
  permit_params :email, :country, :first_name, :last_name, :city, :postal, :title, :address1, :address2, :actionkit_user_id
  actions :all, except: [:destroy]

  sidebar 'Previous Versions', only: :show do
    attributes_table_for member do
      row :versions do
        link_to "There are #{member.versions.length} total versions of this member. Click here to view.", controller: '/versions', action: 'show', model: 'member', id: member.id
      end
    end
  end
end
