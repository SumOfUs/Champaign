# frozen_string_literal: true

# == Schema Information
#
# Table name: campaigns
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

class Campaign < ApplicationRecord
  has_paper_trail
  has_many :pages

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def action_count
    pages.sum(:action_count)
  end

  def donations_count
    pages.sum(:total_donations)
  end
end
