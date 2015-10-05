class LiquidPartial < ActiveRecord::Base
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  validate :one_plugin
  validate :no_unknown_partials

  def partial_names
    LiquidTagFinder.new(content).partial_names
  end

  def plugin_name
    LiquidTagFinder.new(content).plugin_names[0]
  end

  def plugin_refs(ref: nil, depth: 0)
    return if depth > 2
    introspector = LiquidTagFinder.new(content)
    plugin_names = introspector.plugin_names
    collector = plugin_names.empty? ? [] : [[plugin_names[0], ref]]
    introspector.partial_refs.each do |partial, child_ref|
      child_partial = LiquidPartial.where(title: partial).first
      next if child_partial.blank?
      collector += child_partial.plugin_refs(ref: child_ref, depth: depth+1)
    end
    collector
  end

  def one_plugin
    plugin_names = LiquidTagFinder.new(content).plugin_names
    if plugin_names.size > 1
      errors.add(:content, "can only reference one partial, but found #{plugin_names.join(',')}")
    end
  end

  def no_unknown_partials
    LiquidPartial.missing_partials(partial_names).each do |name|
      errors.add :content, "includes unknown partial '#{name}'"
    end
  end

  # Filters array of partial names to those absent from the database. (returns new array)
  def self.missing_partials(names)
    names.reject{|name| LiquidPartial.exists?(title: name) }
  end

end
