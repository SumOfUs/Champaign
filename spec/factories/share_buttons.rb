# frozen_string_literal: true

# == Schema Information
#
# Table name: share_buttons
#
#  id                :integer          not null, primary key
#  analytics         :text
#  share_button_html :string
#  share_type        :string
#  title             :string
#  url               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  page_id           :integer
#  sp_id             :string
#
# Indexes
#
#  index_share_buttons_on_page_id  (page_id)
#

FactoryBot.define do
  factory :share_button, class: 'Share::Button' do
    title { 'MyString' }
    url { 'MyString' }
    page_id { 1 }
    sp_id { 2 }

    trait :facebook do
      share_type { 'facebook' }
      share_button_html { "<div class='sp_162041 sp_fb_large' ></div>" }
    end

    trait :twitter do
      share_type { 'twitter' }
      share_button_html { "<div class='sp_162043 sp_tw_large' ></div>" }
    end

    trait :email do
      share_type { 'email' }
      share_button_html { "<div class='sp_162130 sp_em_large' ></div>" }
    end
  end
end
