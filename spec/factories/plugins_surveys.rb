# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_surveys
#
#  id           :integer          not null, primary key
#  active       :boolean          default(FALSE)
#  auto_advance :boolean          default(TRUE)
#  ref          :string
#  created_at   :datetime
#  updated_at   :datetime
#  page_id      :integer
#
# Indexes
#
#  index_plugins_surveys_on_page_id  (page_id)
#

FactoryBot.define do
  factory :plugins_survey, class: 'Plugins::Survey' do
    active { true }
  end
end
