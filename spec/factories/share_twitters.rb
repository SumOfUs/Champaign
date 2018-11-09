# frozen_string_literal: true
# == Schema Information
#
# Table name: share_twitters
#
#  id          :integer          not null, primary key
#  sp_id       :integer
#  page_id     :integer
#  title       :string
#  description :string
#  button_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :share_twitter, class: 'Share::Twitter' do
    sp_id 1
    page nil
    title 'MyString'
    description 'MyString {LINK}'
    button_id 1
  end
end
