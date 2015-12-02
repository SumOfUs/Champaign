class Plugins::Fundraiser < ActiveRecord::Base
  belongs_to :page
  belongs_to :form
  belongs_to :donation_band

  DEFAULTS = { title: 'Donate now' }

  after_create :create_form

  def liquid_data
    attributes.merge(form_id: form.try(:id), fields: form_fields)
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
