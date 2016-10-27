# frozen_string_literal: true
module Plugins::HasForm
  extend ActiveSupport::Concern

  included do
    before_create :create_form
    has_one :form, as: :formable, dependent: :destroy
  end

  def form_fields
    form ? form.form_elements.map(&:attributes) : []
  end

  def name
    self.class.name.demodulize
  end

  def outstanding_fields(form_values)
    return [] if form.blank?
    FormValidator.new(
      { form_id: form.id }.merge(form_values || {})
    ).errors.keys
  end

  def update_form(new_form)
    return if new_form.blank?
    old_form = form
    update(form: new_form)
    old_form.destroy if old_form.present?
  end

  def dup
    clone = super
    clone.save!

    clone.form.form_elements = form.form_elements.map(&:dup) if clone.form

    clone
  end

  private

  def create_form
    return if form.present? && !form.form_elements.empty?
    locale = try(:page).try(:language).try(:code) || I18n.default_locale
    self.form = FormDuplicator.duplicate(
      DefaultFormBuilder.create(locale: locale)
    )
  end

  def form_liquid_data(supplemental_data)
    {
      form_id: form.try(:id),
      fields: form_fields,
      outstanding_fields: outstanding_fields(
        supplemental_data[:form_values]
      ).map(&:to_s)
    }
  end
end
