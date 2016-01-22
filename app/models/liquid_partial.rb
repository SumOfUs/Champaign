class LiquidPartial < ActiveRecord::Base
  include HasLiquidPartials
  has_paper_trail

  validates :title,   presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  validate :one_plugin

  after_save :invalidate_cache

  def plugin_name
    LiquidTagFinder.new(content).plugin_names[0]
  end

  # Filters array of partial names to those absent from the database. (returns new array)
  def self.missing_partials(names)
    names.reject{|name| LiquidPartial.exists?(title: name) }
  end

  private

  def one_plugin
    plugin_names = LiquidTagFinder.new(content).plugin_names
    if plugin_names.size > 1
      errors.add(:content, "can only reference one partial, but found #{plugin_names.join(',')}")
    end
  end

  def invalidate_cache
    Rails.cache.clear
  end
end

