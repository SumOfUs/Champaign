class LiquidTagFinder

  def initialize(content)
    @content = content
  end

  def template
    @template ||= Liquid::Template.parse(@content)
  end

  def plugin_names
    markups = all_liquid_tags.map{ |li| li.instance_values['markup'] }
    plugins = markups.map{|markup| markup.match(/plugins\.([a-zA-Z0-9_]+)/) }
    return plugins.select(&:present?).map{|matches| matches[1]}.uniq
  end

  def partial_names
    return all_include_tags.map{ |incl| partial_name_from_include(incl) }
  end

  def partial_refs
    all_refs = all_include_tags.map{ |incl| [partial_name_from_include(incl), ref_from_include(incl)] }
    return all_refs.uniq # one form for multiple refless/ same reffed templates
  end

  private

  def all_liquid_tags
    return tree_liquid_tags(template.root.nodelist)
  end

  def all_include_tags
    return all_liquid_tags.select{|node| node.class == Liquid::Include}
  end

  def partial_name_from_include(incl)
    return strip_quotes(incl.instance_values['template_name'])
  end

  def ref_from_include(incl)
    attrs = incl.instance_values['attributes']
    return nil unless attrs.include? 'ref'
    return strip_quotes(attrs['ref'])
  end

  def strip_quotes(str)
    return str.gsub(/\A["']|["']\Z/, '')
  end

  # recursive method to get nodes out of tree format
  def tree_liquid_tags(nodelist)
    liquid_nodes = nodelist.select{|node| node.class.name.include?("Liquid")}.map{|li| [li]}
    nested_nodes = liquid_nodes.map{|li| li[0].try(:nodelist).blank? ? li : li + tree_liquid_tags(li[0].nodelist) }
    return nested_nodes.flatten
  end

end
