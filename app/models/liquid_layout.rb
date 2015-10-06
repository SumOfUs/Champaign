class LiquidLayout < ActiveRecord::Base
  include HasLiquidPartials

  has_many :pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  class << self
    def default
      find_by(title: 'default')
    end
  end
end
