class Plugins::Fundraiser < ActiveRecord::Base
  belongs_to :page
  belongs_to :form
  belongs_to :donation_band

  DEFAULTS = { title: 'Donate now' }

  after_create :create_form

  def liquid_data(supplemental_data={})
    bands = donation_band.present? ? donation_band.internationalize.to_json : "null"
    attributes.merge(
      form_id: form_id,
      fields: form_fields,
      donation_bands: bands,
      outstanding_fields: outstanding_fields(supplemental_data[:form_values]).map(&:to_s)
    )
  end

  def form_fields
    form ? form.form_elements.map(&:attributes) : []
  end

  def name
    self.class.name.demodulize
  end

  def outstanding_fields(form_values)
    return [] if form_id.blank?
    FormValidator.new({form_id: form_id}.merge(form_values || {})).errors.keys
  end

  private

  def create_form
    update(form: Form.create(master: false, name: "fundraiser:#{id}"))
  end
end
