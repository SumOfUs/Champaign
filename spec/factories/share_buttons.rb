# frozen_string_literal: true
FactoryGirl.define do
  factory :share_button, :class => 'Share::Button' do
    title "MyString"
    url "MyString"
    page_id 1

    trait :facebook do
      sp_type "facebook"
      sp_button_html "<div class='sp_162041 sp_fb_large' ></div>"
    end

    trait :twitter do
      sp_type "twitter"
      sp_button_html "<div class='sp_162043 sp_tw_large' ></div>"
    end

    trait :email do
      sp_type "email"
      sp_button_html "<div class='sp_162130 sp_em_large' ></div>"
    end
  end
end
