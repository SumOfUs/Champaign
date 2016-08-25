# frozen_string_literal: true
FactoryGirl.define do
  factory :share_email, class: 'Share::Email' do
    subject 'MyString'
    body 'MyText {LINK}'
    page nil
    sp_id ''
    button_id 1
  end
end
