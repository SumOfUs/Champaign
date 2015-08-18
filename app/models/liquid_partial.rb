class LiquidPartial < ActiveRecord::Base
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
  validate :one_plugin

  def plugin_name
    return LiquidTagFinder.new(content).plugin_names[0]
  end

  def one_plugin
    plugin_names = LiquidTagFinder.new(content).plugin_names
    if plugin_names.size > 1
      errors.add(:content, "can only reference one partial, but found #{plugin_names.join(',')}")
    end
  end

end
