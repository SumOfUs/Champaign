class LiquidPartial < ActiveRecord::Base
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  def plugin_names
    template = Liquid::Template.parse(content)
    liquids = all_liquid_tags(template.root.nodelist)
    markups = liquids.map{ |li| li.instance_values['markup'] }
    plugins = markups.map{|markup| markup.match(/plugins\.([a-zA-Z0-9_]+)/) }
    return plugins.select(&:present?).map{|matches| matches[1]}.uniq
  end

  private

  def all_liquid_tags(nodelist)
    liquid_nodes = nodelist.select{|node| node.class.name.include?("Liquid")}.map{|li| [li]}
    nested_nodes = liquid_nodes.map{|li| li[0].try(:nodelist).blank? ? li : li + all_liquid_tags(li[0].nodelist) }
    return nested_nodes.flatten
  end
end
