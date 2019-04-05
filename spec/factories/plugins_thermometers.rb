# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_thermometers
#
#  id         :integer          not null, primary key
#  active     :boolean          default(FALSE)
#  offset     :integer
#  ref        :string
#  title      :string
#  type       :string           default("ActionsThermometer"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer
#
# Indexes
#
#  index_plugins_thermometers_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

FactoryBot.define do
  factory :plugins_thermometer, class: 'Plugins::Thermometer' do
    title { 'MyString' }
    offset { 1 }
    page { nil }
    active { false }
  end

  factory :plugins_donations_thermometer, parent: :plugins_thermometer, class: 'Plugins::DonationsThermometer' do
    type { 'DonationsThermometer' }
  end

  factory :plugins_actions_thermometer, parent: :plugins_thermometer, class: 'Plugins::ActionsThermometer' do
  end
end
