class Language < ActiveRecord::Base

  has_many :pages

  validates :code, :name, presence: true
end

