# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_thermometers
#
#  id         :integer          not null, primary key
#  title      :string
#  offset     :integer
#  page_id    :integer
#  active     :boolean          default("false")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ref        :string
#

FactoryGirl.define do
  factory :plugins_thermometer, class: 'Plugins::Thermometer' do
    title 'MyString'
    offset 1
    page nil
    active false
  end
end
