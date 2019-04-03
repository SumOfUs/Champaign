# frozen_string_literal: true

module HasLiquidPartials
  extend ActiveSupport::Concern

  included do
    validate :no_unknown_partials
  end

  def no_unknown_partials
    LiquidPartial.missing_partials(partial_names).each do |name|
      errors.add :content, "includes unknown partial '#{name}'"
    end
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

      collector += child_partial.plugin_refs(ref: child_ref, depth: depth + 1)
    end
    collector.uniq
  end

  def partial_names
    LiquidTagFinder.new(content).partial_names
  end

  def partial_refs
    LiquidTagFinder.new(content).partial_refs
  end
end
