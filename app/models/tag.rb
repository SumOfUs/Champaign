# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string
#  actionkit_uri :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Tag < ApplicationRecord
  validates :name, :actionkit_uri, presence: true, uniqueness: true
  has_paper_trail on: %i[update destroy]

  has_many :pages_tags, dependent: :destroy
  has_many :pages, through: :pages_tags

  scope :issue,  -> { where("name LIKE '#%'") }
  scope :region, -> { where("name LIKE '@%'") }
end
