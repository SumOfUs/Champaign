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

  def partial_names
    LiquidTagFinder.new(content).partial_names
  end

  def partial_refs
    LiquidTagFinder.new(content).partial_refs
  end

end