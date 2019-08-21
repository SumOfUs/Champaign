# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_actions
#
#  id           :bigint(8)        not null, primary key
#  bounced_at   :datetime
#  clicked      :string           default([]), is an Array
#  complaint    :boolean
#  confirmed_at :datetime
#  consented    :boolean
#  data         :jsonb
#  delivered_at :datetime
#  email        :string
#  email_count  :integer          default(0)
#  emailed_at   :datetime
#  opened_at    :datetime
#  token        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  page_id      :bigint(8)
#
# Indexes
#
#  index_pending_actions_on_page_id  (page_id)
#

class PendingAction < ApplicationRecord
  scope :not_confirmed, -> { where(confirmed_at: nil) }
  scope :only_emailed_once, -> { where(email_count: 1) }
  scope :not_emailed_last_24, -> { where('emailed_at < ?', 24.hours.ago) }
  scope :not_older_than_20_days, -> { where(arel_table[:created_at].gt(20.days.ago)) }

  belongs_to :page
  belongs_to :member, foreign_key: :email, primary_key: :email

  def self.still_unconfirmed
    PendingAction
      .not_confirmed
      .only_emailed_once
      .not_emailed_last_24
      .not_older_than_20_days
      .joins(:member)
      .where('members.consented is null')
  end
end
