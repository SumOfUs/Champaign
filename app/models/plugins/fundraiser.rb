class Plugins::Fundraiser < ActiveRecord::Base
  belongs_to :page

  DEFAULTS = { title: 'Donate now' }

  def liquid_data
    attributes
  end

  def form_fields
    form ? form.form_elements.map(&:attributes) : []
  end

  def name
    self.class.name.demodulize
  end

end
