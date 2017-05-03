# frozen_string_literal: true
ActiveAdmin.register PhoneNumber do
  actions :all

  permit_params :number, :country
end
