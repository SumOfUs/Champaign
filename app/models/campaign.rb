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

class Campaign < ActiveRecord::Base
  has_paper_trail
  has_many :pages

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def action_count
    pages.sum(:action_count)
  end
end
