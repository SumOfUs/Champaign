# frozen_string_literal: true

ActiveAdmin.register Payment::Braintree::PaymentMethod do
  menu label: 'Express Donation'
  actions :all, except: %i[destroy new]

  permit_params :store_in_vault

  filter :customer_email,  as: :string, filters: [:equals]

  index do
    column :id
    column :email do |m|
      m.customer.email
    end

    column 'Stored', :store_in_vault
    actions
  end

  form do |_f|
    input :store_in_vault
    actions
  end
end
