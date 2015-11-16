class Plugins::Fundraiser < ActiveRecord::Base
  belongs_to :page
  belongs_to :form

  DEFAULTS = { title: 'Donate now' }

  after_create :create_form

  def liquid_data
    attributes
  end

  def form_fields
    form ? form.form_elements.map(&:attributes) : []
  end

  def name
    self.class.name.demodulize
  end

  private

  def create_form
    update(form: Form.create(master: false, name: "fundraiser:#{id}"))
  end
end
