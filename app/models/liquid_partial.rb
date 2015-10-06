class LiquidPartial < ActiveRecord::Base
  include HasLiquidPartials

  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  validate :one_plugin

  def plugin_name
    LiquidTagFinder.new(content).plugin_names[0]
  end

  # This method is used to find all the plugins referenced in both
  # this partial, and any partials included by this partial. It returns
  # an array of [plugin_name, plugin_ref] pairs.
  #
  # The method operates recursively by instantiating other partials
  # that are referenced in this partial and calling this method on them.
  # To avoid circular references, the recursion is only allowed to a depth
  # of 2 subpartials.
  #
  # For examples, see liquid_partial_spec.rb
  #
  def plugin_refs(ref: nil, depth: 0)
    return [] if depth > 2
    introspector = LiquidTagFinder.new(content)
    plugin_names = introspector.plugin_names
    collector = plugin_names.empty? ? [] : [[plugin_names[0], ref]]
    introspector.partial_refs.each do |partial, child_ref|
      child_partial = LiquidPartial.where(title: partial).first
      next if child_partial.blank?
      collector += child_partial.plugin_refs(ref: child_ref, depth: depth+1)
    end
    collector.uniq
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

end
