FactoryGirl.define do
  factory :share_twitter, :class => 'Share::Twitter' do
    sp_id 1
campaign_page nil
title "MyString"
description "MyString"
button_id 1
  end

end
