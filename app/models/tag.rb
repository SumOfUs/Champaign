# frozen_string_literal: true
class Tag < ActiveRecord::Base
  validates :name, :actionkit_uri, presence: true, uniqueness: true
  has_paper_trail on: [:update, :destroy]

  has_many :pages_tags, dependent: :destroy
  has_many :pages, through: :pages_tags
end

