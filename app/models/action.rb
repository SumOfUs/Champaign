# frozen_string_literal: true

# == Schema Information
#
# Table name: actions
#
#  id                :integer          not null, primary key
#  created_user      :boolean
#  donation          :boolean          default(FALSE)
#  form_data         :jsonb
#  link              :string
#  publish_status    :integer          default("default"), not null
#  subscribed_member :boolean          default(TRUE)
#  subscribed_user   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  member_id         :integer
#  page_id           :integer
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

class Action < ApplicationRecord
  belongs_to :page, counter_cache: :action_count
  belongs_to :member

  enum publish_status: %i[default published hidden]

  has_paper_trail on: %i[update destroy]
  scope :donation, -> { where(donation: true) }
  scope :not_donation, -> { where.not(donation: true) }
end
