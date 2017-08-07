module HasTargets
  extend ActiveSupport::Concern

  included do
    validate :targets_are_valid, if: :targets_changed?
  end

  module ClassMethods
    attr_reader :target_class

    private

    def set_target_class(target_class)
      @target_class = target_class
    end
  end

  def targets=(target_objects)
    write_attribute :targets, target_objects.map(&:to_hash)
  end

  def targets
    json_targets.map { |t| target_class.new(t) }
  end

  def target_fields
    targets.inject([]) { |mem, t| mem | t.keys }
  end

  def target_filterable_fields
    target_fields - target_class.not_filterable_attributes
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

  def target_class
    self.class.target_class
  end
end
