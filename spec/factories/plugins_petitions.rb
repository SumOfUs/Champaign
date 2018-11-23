# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_petitions
#
#  id          :integer          not null, primary key
#  page_id     :integer
#  active      :boolean          default("false")
#  form_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  ref         :string
#  target      :string
#  cta         :string
#

FactoryBot.define do
  factory :plugins_petition, class: 'Plugins::Petition' do
    page { nil }
    active { false }
    form { nil }
    cta { 'Sign the Petition' }
    target { 'The man' }
    description { 'Gotta save the world and stuff' }
  end
end
