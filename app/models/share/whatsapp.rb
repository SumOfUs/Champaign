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
    query = "?source=whatsapp&variant_id=#{id}"
    copy = text.gsub('{LINK}', "#{button.url}#{query}")
    button.share_button_html.gsub('{TEXT}', ERB::Util.url_encode(copy))
  end
end
