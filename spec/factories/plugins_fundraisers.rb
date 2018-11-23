# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_fundraisers
#
#  id                :integer          not null, primary key
#  title             :string
#  ref               :string
#  page_id           :integer
#  active            :boolean          default("false")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  form_id           :integer
#  donation_band_id  :integer
#  recurring_default :integer          default("0"), not null
#  preselect_amount  :boolean          default("false")
#

FactoryBot.define do
  factory :plugins_fundraiser, class: 'Plugins::Fundraiser' do
    title { 'Donate now' }
    ref { nil }
    active { false }
  end
end
