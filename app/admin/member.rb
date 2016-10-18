# frozen_string_literal: true
ActiveAdmin.register Member do
  permit_params :email,
                :country,
                :first_name,
                :last_name,
                :city,
                :postal,
                :title,
                :address1,
                :address2,
                :actionkit_member_id

  index pagination_total: false
  config.per_page = 20
  scope :active, show_count: false

  filter :email
  filter :country
  filter :first_name
  filter :last_name
  filter :city
  filter :postal
  filter :donor_status
  filter :created_at
  filter :updated_at

  actions :all, except: [:destroy]

  sidebar 'Previous Versions', only: :show do
    attributes_table_for member do
      row :versions do
        render '/versions/versions_link', model: member, model_name: 'member'
      end
    end
  end
end
