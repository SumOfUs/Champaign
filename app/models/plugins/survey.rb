class Plugins::Survey < ActiveRecord::Base
  has_many :forms, -> { order(created_at: :asc) }, as: :formable, dependent: :destroy

  belongs_to :page, touch: true

  DEFAULTS = {}

  def liquid_data(supplemental_data = {})
    attributes.merge(forms: forms.includes(:form_elements).map { |form| form_liquid_data(form) } )
  end

  def name
    self.class.name.demodulize
  end

  def form_liquid_data(form)
    {
      form_id: form.try(:id),
      fields: form.form_elements.map(&:attributes),
      outstanding_fields: form.form_elements.map(&:name),
      skippable: !form.form_elements.map(&:required).any?
    }
  end
end
