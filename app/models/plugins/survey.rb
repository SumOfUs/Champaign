# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_surveys
#
#  id           :integer          not null, primary key
#  page_id      :integer
#  active       :boolean          default("false")
#  ref          :string
#  created_at   :datetime
#  updated_at   :datetime
#  auto_advance :boolean          default("true")
#

class Plugins::Survey < ApplicationRecord
  has_many :forms, -> { order(position: :asc, created_at: :asc) }, as: :formable, dependent: :destroy

  belongs_to :page, touch: true
  after_create :ensure_required_fields

  DEFAULTS = {}.freeze
  REQUIRED_FIELDS = [:email].freeze

  def liquid_data(_supplemental_data = {})
    attributes.merge(forms: forms.includes(:form_elements).map { |form| form_liquid_data(form) })
  end

  def name
    self.class.name.demodulize
  end

  def required_form_elements
    REQUIRED_FIELDS.map do |field|
      relevant = fields_with_name(field)
      relevant.size == 1 ? relevant[0].id : nil
    end.compact
  end

  def ensure_required_fields
    ensure_has_a_form
    REQUIRED_FIELDS.each do |field|
      next unless fields_with_name(field).empty?
      language = page.try(:language).try(:code) || I18n.default_locale
      data_type = FormElement::VALID_TYPES.include?(field.to_s) ? field : 'text'
      FormElement.create(name: field,
                         data_type: data_type,
                         form: forms.first,
                         required: true,
                         label: I18n.t("form.default.#{field}", locale: language))
      forms.first.reload
    end
  end

  def ensure_has_a_form
    return forms if forms.size >= 1
    Form.create(name: "survey_form_#{id}", master: false, formable: self)
    forms.reload
  end

  def form_liquid_data(form)
    {
      form_id: form.try(:id),
      fields: form.form_elements.map(&:liquid_data),
      outstanding_fields: form.form_elements.map(&:name),
      skippable: form.form_elements.map(&:required).none?
    }
  end

  private

  def fields_with_name(name)
    forms.map(&:form_elements).flatten.select { |el| el.name.to_sym == name }
  end
end
