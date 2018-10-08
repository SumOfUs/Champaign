# frozen_string_literal: true

ActiveAdmin.register RegisteredTargetEndpoint do
  actions :all

  permit_params :url, :name, :description
end
