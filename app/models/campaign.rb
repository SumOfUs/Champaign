# frozen_string_literal: true
class Campaign < ActiveRecord::Base
  has_paper_trail
  has_many :pages

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end

