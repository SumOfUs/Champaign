class LiquidPartial < ActiveRecord::Base
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  def plugin_names
    tag_finder = LiquidTagFinder.new(content)
    return tag_finder.plugin_names
  end
end
