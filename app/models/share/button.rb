# frozen_string_literal: true

# == Schema Information
#
# Table name: share_buttons
#
#  id             :integer          not null, primary key
#  title          :string
#  url            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  sp_id          :string
#  page_id        :integer
#  share_type        :string
#  share_button_html :string
#  analytics      :text
#

class Share::Button < ApplicationRecord
  belongs_to :page
  validates :url, presence: true, allow_blank: false

  def share_progress?
    # the share types currently managed by share progress
    %w[facebook twitter email].include? share_type
  end

  scope :share_progress, -> { where share_type: %w[facebook twitter email] }
end
