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
#  click_count :integer
#  conversion_count :integer

FactoryBot.define do
  factory :share_whatsapp, class: 'Share::Whatsapp' do
    page nil
    text 'MyMessage {LINK}'
    button_id 1
    click_count 0
    conversion_count 0
  end
end
