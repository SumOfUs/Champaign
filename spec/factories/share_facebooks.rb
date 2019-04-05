# frozen_string_literal: true

# == Schema Information
#
# Table name: share_facebooks
#
#  id          :integer          not null, primary key
#  click_count :integer
#  description :text
#  image       :string
#  share_count :integer
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  button_id   :integer
#  image_id    :integer
#  page_id     :integer
#  sp_id       :string
#
# Indexes
#
#  index_share_facebooks_on_button_id  (button_id)
#  index_share_facebooks_on_image_id   (image_id)
#  index_share_facebooks_on_page_id    (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (image_id => images.id)
#

FactoryBot.define do
  factory :share_facebook, class: 'Share::Facebook' do
    title { 'MyString' }
    description { 'MyText' }
    page
    button_id { 1 }
  end
end
