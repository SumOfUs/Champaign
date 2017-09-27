# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_surveys
#
#  id           :integer          not null, primary key
#  page_id      :integer
#  active       :boolean          default("false")
#  ref          :string
#  created_at   :datetime
#  updated_at   :datetime
#  auto_advance :boolean          default("true")
#

FactoryGirl.define do
  factory :plugins_survey, class: 'Plugins::Survey' do
    active true
  end
end
