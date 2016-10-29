# frozen_string_literal: true
class Plugins::Text < ActiveRecord::Base
  belongs_to :page, touch: true

  DEFAULTS = {}.freeze

  def liquid_data(_supplemental_data = {})
    attributes
  end

  def name
    self.class.name.demodulize
  end
end
