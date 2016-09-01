class Plugins::Survey < ActiveRecord::Base
  has_many :forms, as: :formable, dependent: :destroy

  belongs_to :page, touch: true

  DEFAULTS = {}

  def liquid_data(supplemental_data = {})
    attributes.merge(forms: forms.map { |form| form_liquid_data(form) } )
  end

  def name
    self.class.name.demodulize
  end

  def form_liquid_data(form)
    {
      form_id: form.try(:id),
      fields: form.form_elements.map(&:attributes),
      outstanding_fields: outstanding_fields({}).map(&:to_s)
    }
  end
end
