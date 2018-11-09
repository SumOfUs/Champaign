# frozen_string_literal: true
# == Schema Information
#
# Table name: share_emails
#
#  id         :integer          not null, primary key
#  subject    :string
#  body       :text
#  page_id    :integer
#  sp_id      :string
#  button_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :share_email, class: 'Share::Email' do
    subject 'MyString'
    body 'MyText {LINK}'
    page nil
    sp_id ''
    button_id 1
  end
end
