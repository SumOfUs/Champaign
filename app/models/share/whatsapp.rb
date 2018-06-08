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

class Share::Whatsapp < ApplicationRecord
  include Share::Variant

  validates :text, presence: true
  validate :link?, unless: -> { text.nil? }

  def link?
    errors.add(:text, 'does not contain {LINK}') unless text.match?(/\{LINK\}/)
  end
end
