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

  def html
    # Prepend the desired query parameters (uri encoded) into the url we want {LINK} to point to.
    # Then construct the whole share URL by replacing the {LINK} with that.
    query = "?src=whatsapp&variant_id=#{id}"
    copy = text.gsub('{LINK}', "#{button.url}#{query}")
    button.share_button_html.gsub('{TEXT}', ERB::Util.url_encode(copy))
  end
end
