# frozen_string_literal: true

# == Schema Information
#
# Table name: share_emails
#
#  id         :integer          not null, primary key
#  body       :text
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  button_id  :integer
#  page_id    :integer
#  sp_id      :string
#
# Indexes
#
#  index_share_emails_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

class Share::Email < ApplicationRecord
  include Share::Variant

  validates :subject, :body, presence: true
  validate :has_link, unless: -> { body.nil? }

  def has_link
    errors.add(:body, 'does not contain {LINK}') unless body.match?(/\{LINK\}/)
  end
end
