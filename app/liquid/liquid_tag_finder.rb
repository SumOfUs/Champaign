class LiquidTagFinder

  def initialize(content)
    @content = content
  end

  def template
    @template ||= Liquid::Template.parse(@content)
  end

  def tree_liquid_tags(nodelist)
    liquid_nodes = nodelist.select{|node| node.class.name.include?("Liquid")}.map{|li| [li]}
    nested_nodes = liquid_nodes.map{|li| li[0].try(:nodelist).blank? ? li : li + tree_liquid_tags(li[0].nodelist) }
    return nested_nodes.flatten
  end

  def all_liquid_tags
    return tree_liquid_tags(template.root.nodelist)
  end

  def plugin_names
    markups = all_liquid_tags.map{ |li| li.instance_values['markup'] }
    plugins = markups.map{|markup| markup.match(/plugins\.([a-zA-Z0-9_]+)/) }
    return plugins.select(&:present?).map{|matches| matches[1]}.uniq
  end

  def partial_names
    includes = all_liquid_tags.select{|node| node.class == Liquid::Include}
    return includes.map{ |li| li.instance_values['template_name'].gsub(/\A["']|["']\Z/, '') }
  end
end
