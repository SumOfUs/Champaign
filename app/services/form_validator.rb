class FormValidator
  attr_reader :errors

  def initialize(params)
    @params = params.symbolize_keys
    @errors =  Hash.new{ |hash, key| hash[key] = [] }
    validate
  end

  def form
    @form ||= Form.includes(:form_elements).find(@params[:form_id])
  end

  def valid?
    @errors.empty?
  end

  def validate
    form.form_elements.each do |element|
      validate_field(element)
      validate_length(element) if element.data_type.inquiry.text?
    end
  end

  def validate_length(element)
    return unless @params[:name]

    name = element.name.to_sym
    @errors[name] << I18n.t('validation.is_invalid_length') if @params.fetch(name, []).size >= 250
  end

  def validate_field(form_element)
    el_name = form_element.name.to_sym

    validate_required( form_element, el_name)
    validate_country(  form_element, el_name)
    validate_phone(    form_element, el_name)
    validate_email(    form_element, el_name)
    validate_postal(   form_element, el_name)
  end

  private

  def validate_required(form_element, el_name)
    if form_element.required? && @params[el_name].blank?
      @errors[el_name] << I18n.t("validation.is_required")
    end
  end

  def validate_phone(form_element, el_name)
    phone_number = @params[el_name]
    if form_element.data_type == "phone" && phone_number.present? && !is_phone(phone_number)
      @errors[el_name] << I18n.t("validation.is_invalid_phone")
    end
  end

  def validate_email(form_element, el_name)
    email = @params[el_name]
    if form_element.data_type == "email" && email.present? && !is_email(email)
      @errors[el_name] << I18n.t("validation.is_invalid_email")
    end
  end

  def validate_country(form_element, el_name)
    country = @params[el_name]
    if form_element.data_type == "country" && country.present? && !is_country_code(country)
      @errors[el_name] << I18n.t("validation.is_invalid_country")
    end
  end

  def validate_postal(form_element, el_name)
    postal = @params[el_name]
    country = (@params[:country].blank? ? :US : @params[:country].to_sym)

    if form_element.data_type == 'postal' && postal.present? && !is_postal(postal, country)
      @errors[el_name] << I18n.t('validation.is_invalid_postal')
    end
  end

  def is_email(candidate)
    (/\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\z/i =~ candidate).present?
  end

  def is_phone(candidate)
    no_extra_characters = (/\A[0-9\-\+\(\) ]+\z/i =~ candidate).present?
    has_six_numbers = (candidate.scan(/[0-9]/).size > 5)
    no_extra_characters && has_six_numbers
  end

  def is_country_code(candidate)
    ISO3166::Country.all_names_with_codes.map(&:last).include?(candidate)
  end

  def is_postal(candidate, country)
    PostalValidator.valid?(candidate, country_code: country)
  end
end

