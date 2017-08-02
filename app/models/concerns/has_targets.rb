module HasTargets
  extend ActiveSupport::Concern

  included do
    validate :targets_are_valid, if: :targets_changed?
  end

  module ClassMethods
    attr_reader :tool_module

    private

    def use_tool_module(desired)
      @tool_module = desired
    end
  end

  def targets=(target_objects)
    write_attribute :targets, target_objects.map(&:to_hash)
  end

  def targets
    json_targets.map { |t| tool_module::Target.new(t) }
  end

  def empty_cols
    targets.collect(&:keys).flatten.uniq.select do |field|
      json_targets.map { |t| t[field] || (t['fields'] && t['fields'][field]) }.compact.empty?
    end
  end

  def target_keys
    unfilterable = (tool_module::Target::MAIN_ATTRS - tool_module::Target::FILTERABLE).map(&:to_s)
    discarded = unfilterable + empty_cols
    targets
      .collect(&:keys)
      .flatten
      .uniq
      .reject { |k| discarded.include?(k) }
  end

  def find_target(id)
    targets.find { |t| t.id == id }
  end

  private

  def json_targets
    read_attribute(:targets)
  end

  def targets_are_valid
    targets.each_with_index.each do |target, index|
      target.valid?
      target.errors.full_messages.each do |message|
        errors.add(:targets, "#{message} (row #{index + 1})")
      end
    end
  end

  def tool_module
    self.class.tool_module
  end
end
