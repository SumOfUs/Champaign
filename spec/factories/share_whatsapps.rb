# frozen_string_literal: true

# == Schema Information
#
# Table name: share_whatsapps
#
#  id          :integer          not null, primary key
#  page_id     :integer
#  text       :string
#  button_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :share_whatsapp, class: 'Share::Whatsapp' do
    id 1
    page nil
    text 'MyMessage {LINK}'
    button_id 1
  end
end
