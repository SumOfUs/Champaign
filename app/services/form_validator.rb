# frozen_string_literal: true

class FormValidator
  MAX_LENGTH = {
    PARAGRAPH: 10_000,
    TEXT: 250
  }.freeze

  EMAIL_REGEXP = /\A(?!\.)(?!.*\.{2})(?!.*@\.)(?!.*\.+@)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\z/i.freeze

  def initialize(params, form_elements = nil)
    @params = params.symbolize_keys
    @errors = Hash.new { |hash, key| hash[key] = [] }
    @form_elements = form_elements unless form_elements.blank? # don't prevent memoization
    validate
  end

  def valid?
    @errors.empty?
  end

  def validate
    form_elements.each do |element|
      validate_field(element)
    end
  end

  def errors
    @errors.symbolize_keys
  end

  private

  def form_elements
    return @form_elements if @form_elements.present?

    if @params[:form_id].present?
      form = Form.includes(:form_elements).find(@params[:form_id])
      @form_elements = form.form_elements.map do |el|
        { name: el.name.to_sym, required: el.required?, data_type: el.data_type }
      end
    else
      []
    end
  end

  def validate_field(form_element)
    value = @params[form_element[:name].to_sym]
    validate_length(value, form_element)
    validate_country(value, form_element)
    validate_phone(value, form_element)
    validate_email(value, form_element)
    validate_postal(value, form_element)
    validate_required(value, form_element)
    validate_checkbox(value, form_element)
  end

  def validate_length(value, form_element)
    if form_element[:data_type] == 'text' && (value || []).size >= MAX_LENGTH[:TEXT]
      @errors[form_element[:name]] << I18n.t('validation.is_invalid_length', length: MAX_LENGTH[:TEXT])
    elsif form_element[:data_type] == 'paragraph' && (value || []).size >= MAX_LENGTH[:PARAGRAPH]
      @errors[form_element[:name]] << I18n.t('validation.is_invalid_length', length: MAX_LENGTH[:PARAGRAPH])
    end
  end

  def validate_required(value, form_element)
    return unless form_element[:required] && value.blank?

    @errors[form_element[:name]] << I18n.t('validation.is_required')
  end

  def validate_checkbox(value, form_element)
    return unless form_element[:data_type] == 'checkbox' && form_element[:required]
    return if value.present? && !value.nil? && value.to_s != '0'

    @errors[form_element[:name]] << I18n.t('validation.is_required')
  end

  def validate_phone(phone_number, form_element)
    if form_element[:data_type] == 'phone' && phone_number.present? && !is_phone(phone_number)
      @errors[form_element[:name]] << I18n.t('validation.is_invalid_phone')
    end
  end

  def validate_email(value, form_element)
    email = value.try(:encode, 'UTF-8', invalid: :replace, undef: :replace)
    if form_element[:data_type] == 'email' && email.present? && !is_email?(email)
      @errors[form_element[:name]] << I18n.t('validation.is_invalid_email')
    end
  end

  def validate_country(country, form_element)
    if form_element[:data_type] == 'country' && country.present? && !is_country_code(country)
      @errors[form_element[:name]] << I18n.t('validation.is_invalid_country')
    end
  end

  def validate_postal(postal, form_element)
    return if form_element[:data_type] != 'postal' || postal.blank?

    country = (@params[:country].blank? ? :US : @params[:country].to_sym)
    validator = PostalValidator.new(postal, country_code: country)

    @errors[form_element[:name]] += validator.errors unless validator.valid?
  end

  def is_email?(candidate)
    !(EMAIL_REGEXP =~ candidate).nil?
  end

  def is_phone(candidate)
    no_extra_characters = (/\A[0-9\-\+\(\) ]+\z/i =~ candidate).present?
    has_six_numbers = (candidate.scan(/[0-9]/).size > 5)
    no_extra_characters && has_six_numbers
  end

  def is_country_code(candidate)
    ISO3166::Country.all_names_with_codes.map(&:last).include?(candidate)
  end
end
