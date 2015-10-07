class LiquidLayout < ActiveRecord::Base
  include HasLiquidPartials

  has_many :pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  # IMPORTANT: for the time being we assume that plugins exist
  # only in partials, and are not directly referenced in layouts themselves
  def plugin_refs
    partial_refs.map do |partial, ref|
      LiquidPartial.find_by(title: partial).plugin_refs(ref: ref)
    end.flatten(1).uniq
  end

  class << self
    def default
      find_by(title: 'default')
    end
  end
end
