# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_fundraisers
#
#  id                :integer          not null, primary key
#  active            :boolean          default(FALSE)
#  preselect_amount  :boolean          default(FALSE)
#  recurring_default :integer          default("one_off"), not null
#  ref               :string
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  donation_band_id  :integer
#  form_id           :integer
#  page_id           :integer
#
# Indexes
#
#  index_plugins_fundraisers_on_donation_band_id  (donation_band_id)
#  index_plugins_fundraisers_on_form_id           (form_id)
#  index_plugins_fundraisers_on_page_id           (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (donation_band_id => donation_bands.id)
#  fk_rails_...  (form_id => forms.id)
#  fk_rails_...  (page_id => pages.id)
#

FactoryBot.define do
  factory :plugins_fundraiser, class: 'Plugins::Fundraiser' do
    title { 'Donate now' }
    ref { nil }
    active { false }
    association :page, factory: :page
  end
end
