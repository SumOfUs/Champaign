# frozen_string_literal: true

# == Schema Information
#
# Table name: share_whatsapps
#
#  id               :bigint(8)        not null, primary key
#  click_count      :integer          default(0), not null
#  conversion_count :integer          default(0), not null
#  text             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  button_id        :integer
#  page_id          :bigint(8)
#
# Indexes
#
#  index_share_whatsapps_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

FactoryBot.define do
  factory :share_whatsapp, class: 'Share::Whatsapp' do
    page { nil }
    text { 'MyMessage {LINK}' }
    button_id { 1 }
    click_count { 0 }
    conversion_count { 0 }
  end
end
