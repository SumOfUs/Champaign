# frozen_string_literal: true
ActiveAdmin.register DonationBand do
  actions :all, except: [:new, :edit]

  index pagination_total: false
  config.per_page = 20
  scope :active, show_count: false
  config.filters = false

  sidebar 'Previous Versions', only: :show do
    attributes_table_for donation_band do
      row :versions do
        render '/versions/versions_link', model: donation_band, model_name: 'donation band'
      end
    end
  end
end
