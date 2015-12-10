module Plugins::HasForm
  extend ActiveSupport::Concern

  included do
    belongs_to :form
    after_create :create_form
  end

  def form_fields
    form ? form.form_elements.map(&:attributes) : []
  end

  def name
    self.class.name.demodulize
  end

  def outstanding_fields(form_values)
    return [] if form.blank?
    FormValidator.new({form_id: form_id}.merge(form_values || {})).errors.keys
  end

  private

  def create_form
    update(form: Form.create(master: false, name: "#{name}:#{id}"))
  end

  def form_liquid_data(supplemental_data)
    {
      form_id: form.try(:id),
      fields: form_fields,
      outstanding_fields: outstanding_fields(supplemental_data[:form_values]).map(&:to_s)
    }
  end
end