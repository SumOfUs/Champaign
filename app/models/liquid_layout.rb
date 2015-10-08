class LiquidLayout < ActiveRecord::Base
  include HasLiquidPartials

  has_many :pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  def plugin_refs
    # pass depth of -1 to allow layouts one more level of nesting than partials
    super(depth: -1)
  end

  class << self
    def default
      find_by(title: 'default')
    end
  end
end
