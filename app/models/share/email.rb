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

class Share::Email < ActiveRecord::Base
  include Share::Variant

  validates :subject, :body, presence: true
  validate :has_link, unless: -> { body.nil? }

  def has_link
    errors.add(:body, 'does not contain {LINK}') unless body.match?(/\{LINK\}/)
  end
end
