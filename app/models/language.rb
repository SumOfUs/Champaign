# frozen_string_literal: true
class Language < ActiveRecord::Base
  has_paper_trail on: [:update, :destroy]
  has_many :pages

  validates :code, :actionkit_uri, :name, presence: true, allow_blank: false
end

