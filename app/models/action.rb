# frozen_string_literal: true
# == Schema Information
#
# Table name: actions
#
#  id                :integer          not null, primary key
#  page_id           :integer
#  member_id         :integer
#  link              :string
#  created_user      :boolean
#  subscribed_user   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  form_data         :jsonb
#  subscribed_member :boolean          default(TRUE)
#  donation          :boolean          default(FALSE)
#  publish_status    :integer          default(0), not null
#

class Action < ActiveRecord::Base
  belongs_to :page, counter_cache: :action_count
  belongs_to :member

  enum publish_status: [:default, :published, :hidden]

  has_paper_trail on: [:update, :destroy]
  scope :donation, -> { where(donation: true) }
  scope :not_donation, -> { where.not(donation: true) }
end
