# frozen_string_literal: true
# The <tt>LiquidTagFinder</tt> class is used to help the app understand
# the needs and the setup of liquid layouts and partials by parsing
# relevant liquid tags.
#
# An instance is initialized with a string holding the liquid markup
# to be analyzed. Each instance exposes five public methods which are
# documented inline.
#
# This class's functionality hinges on accessing instance variables
# of the +Liquid+ parser's internal classes. For that reason, it may be
# a bit fragile and break if the Liquid version changes. It was designed
# with Liquid version 3.0.3.
#
class LiquidTagFinder
  def initialize(content)
    @content = content
  end

  def template
    @template ||= Liquid::Template.parse(@content)
  end

  # Returns the name of every plugin referenced in the liquid markup.
  # For example, if there is any liquid tag (whether flow control or
  # display) that references +plugins.petition[ref].fields+, then
  # 'petition' will be in the list returned by this method.
  def plugin_names
    markups = all_liquid_tags.map { |li| li.instance_values['markup'] }
    plugins = markups.compact.map { |markup| markup.match(/plugins\.([a-zA-Z0-9_]+)/) }
    plugins.select(&:present?).map { |matches| matches[1] }.uniq
  end

  # Returns the names of every partial referenced in the liquid markup.
  # More examples can be found in the LiquidTagFinderSpec
  # For example:
  #     {% include 'thermometer', ref: 'modal' %} {% include 'fundraiser' %}
  # would yield
  #     ['thermometer', 'fundraiser']
  def partial_names
    all_include_tags.map { |incl| partial_name_from_include(incl) }
  end

  # Returns the names of every partial referenced in the liquid markup,
  # along with the ref passed with it. More examples in the spec.
  # Refs serve to allow multiple of one plugin on a page.
  # For example:
  #     {% include 'thermometer', ref: 'modal' %} {% include 'fundraiser' %} {% include 'thermometer' %}
  # would yield
  #     [['thermometer', 'modal'], ['fundraiser', nil], ['thermometer', nil]]
  def partial_refs
    all_refs = all_include_tags.map { |incl| [partial_name_from_include(incl), ref_from_include(incl)] }
    all_refs.uniq # one form for multiple refless/ same reffed templates
  end

  # Looks for a liquid comment like
  #   {% comment %} Description: this is the description {% endcomment %}
  # If one is not found, it will return +nil+. If one is found, it will return
  #   'this is the description'
  def description
    string_search(/description: *(.+)/i, string_comments.flatten)
  end

  # Looks for a liquid comment like {% comment %} Experimental: true {% endcomment %}
  def experimental?
    has_comment?('experimental')
  end

  # Looks for a liquid comment like {% comment %} Skip smoke tests: true {% endcomment %}
  def skip_smoke_tests?
    has_comment?('skip smoke tests')
  end

  # Looks for a liquid comment like {% comment %} Primary layout: true {% endcomment %}
  def primary_layout?
    has_comment?('primary layout')
  end

  # Looks for a liquid comment like {% comment %} Post-action layout: true {% endcomment %}
  def post_action_layout?
    has_comment?('post-action layout')
  end

  # Looks for a liquid comment like
  #   {% comment %} Key: true {% endcomment %}
  # If the tag is found and the value is +true+, this returns +true+.
  # Otherwise it returns +false+.
  def has_comment?(key)
    status = string_search(/#{Regexp.quote(key)}: *(.+)/i, string_comments.flatten)
    status.present? ? status.match(/true/i).present? : false
  end

  private

  def string_comments
    all_comment_tags.map { |node| node.nodelist.select { |subnode| subnode.is_a? String } }
  end

  def all_liquid_tags
    tree_liquid_tags(template.root.nodelist)
  end

  def all_comment_tags
    all_liquid_tags.select do |node|
      (node.class == Liquid::Comment) && !node.nodelist.empty?
    end
  end

  def all_include_tags
    all_liquid_tags.select { |node| node.class == Liquid::Include }
  end

  def partial_name_from_include(incl)
    strip_quotes(incl.instance_values['template_name_expr'])
  end

  def ref_from_include(incl)
    attrs = incl.instance_values['attributes']
    return nil unless attrs.include? 'ref'
    strip_quotes(attrs['ref'])
  end

  def strip_quotes(str)
    str.gsub(/\A["']|["']\Z/, '')
  end

  # regex: a regex with a capturing group. returns the captured text in first string to match the regex
  # candidates: an array of strings to search for the regex in
  def string_search(regex, candidates)
    matches = candidates.map { |comment| comment.match(regex) }
    re_sult = matches.select { |m| m.present? && m[1].length }.first
    re_sult.present? ? re_sult[1].strip : nil
  end

  # recursive method to get nodes out of tree format
  def tree_liquid_tags(nodelist)
    liquid_nodes = nodelist.select { |node| node.class.name.include?('Liquid') }.map { |li| [li] }
    nested_nodes = liquid_nodes.map { |li| li[0].try(:nodelist).blank? ? li : li + tree_liquid_tags(li[0].nodelist) }
    nested_nodes.flatten
  end
end
