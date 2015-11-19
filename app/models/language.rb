class Language < ActiveRecord::Base
  has_paper_trail on: [:update, :destroy]
  has_many :pages

  validates :code, :name, presence: true
end

