ActiveAdmin.register Member do
  permit_params :email, :country, :first_name, :last_name, :city, :postal, :title, :address1, :address2, :actionkit_user_id
  actions :all, except: [:destroy]
end
