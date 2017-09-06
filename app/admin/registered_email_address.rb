# frozen_string_literal: true

ActiveAdmin.register RegisteredEmailAddress do
  actions :all

  permit_params :email, :name
end
