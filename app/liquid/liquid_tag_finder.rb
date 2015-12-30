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
    plugins.select(&:present?).map{|matches| matches[1]}.uniq
  end

  def partial_names
    all_include_tags.map{ |incl| partial_name_from_include(incl) }
  end

  def partial_refs
    all_refs = all_include_tags.map{ |incl| [partial_name_from_include(incl), ref_from_include(incl)] }
    all_refs.uniq # one form for multiple refless/ same reffed templates
  end

  def description
    string_search(/description: *(.+)/i, string_comments.flatten)
  end

  def experimental?
    status = string_search(/experimental: *(.+)/i, string_comments.flatten)
    status.present? ? status.match(/true/i).present? : false
  end

  private

  def string_comments
    all_comment_tags.map{ |node| node.instance_values['nodelist'].select{|subnode| subnode.is_a? String } }
  end

  def all_liquid_tags
    tree_liquid_tags(template.root.nodelist)
  end

  def all_comment_tags
    all_liquid_tags.select do |node|
      (node.class == Liquid::Comment) && node.instance_values['nodelist'].length > 0
    end
  end

  def all_include_tags
    all_liquid_tags.select{|node| node.class == Liquid::Include}
  end

  def partial_name_from_include(incl)
    strip_quotes(incl.instance_values['template_name'])
  end

  def ref_from_include(incl)
    attrs = incl.instance_values['attributes']
    return nil unless attrs.include? 'ref'
    return strip_quotes(attrs['ref'])
  end

  def strip_quotes(str)
    str.gsub(/\A["']|["']\Z/, '')
  end

  # regex: a regex with a capturing group. returns the captured text in first string to match the regex
  # candidates: an array of strings to search for the regex in
  def string_search(regex, candidates)
    matches = candidates.map{ |comment| comment.match(regex) }
    re_sult = matches.select{ |m| m.present? && m[1].length }.first
    re_sult.present? ? re_sult[1].strip : nil
  end

  # recursive method to get nodes out of tree format
  def tree_liquid_tags(nodelist)
    liquid_nodes = nodelist.select{|node| node.class.name.include?("Liquid")}.map{|li| [li]}
    nested_nodes = liquid_nodes.map{|li| li[0].try(:nodelist).blank? ? li : li + tree_liquid_tags(li[0].nodelist) }
    nested_nodes.flatten
  end

end
