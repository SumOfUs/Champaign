class LiquidPartial < ActiveRecord::Base
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  # here we assume there's only one plugin per partial,
  # but that needs a validation still
  def plugin_name
    return LiquidTagFinder.new(content).plugin_names[0]
  end


end
