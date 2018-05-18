# frozen_string_literal: true

class PendingAction < ApplicationRecord
  scope :not_confirmed, -> { where(confirmed_at: nil) }
  scope :only_emailed_once, -> { where(email_count: 1) }
  scope :not_emailed_last_24, -> { where('emailed_at < ?', 24.hours.ago) }

  belongs_to :page
end
