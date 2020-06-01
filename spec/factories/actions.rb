# frozen_string_literal: true

# == Schema Information
#
# Table name: actions
#
#  id                       :integer          not null, primary key
#  clicked_copy_body_button :boolean          default(FALSE)
#  created_user             :boolean
#  donation                 :boolean          default(FALSE)
#  form_data                :jsonb
#  link                     :string
#  publish_status           :integer          default("default"), not null
#  subscribed_member        :boolean          default(TRUE)
#  subscribed_user          :boolean
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  member_id                :integer
#  page_id                  :integer
#
# Indexes
#
#  index_actions_on_member_id  (member_id)
#  index_actions_on_page_id    (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (page_id => pages.id)
#

FactoryBot.define do
  factory :action do
    page { nil }
    member { nil }
    link { 'MyString' }
    created_user { false }
    subscribed_user { false }

    trait :with_member_and_page do
      member
      page
    end
  end
end
