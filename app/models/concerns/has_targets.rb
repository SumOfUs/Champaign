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

  def target_fields
    targets.inject([]) { |mem, t| mem | t.keys }
  end

  def target_filterable_fields
    target_fields - tool_module::Target::NOT_FILTERABLE.map(&:to_s)
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
