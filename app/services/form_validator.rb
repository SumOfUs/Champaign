class FormValidator

  def initialize(params)
    @params = params.symbolize_keys
  end

  def form
    @form ||= Form.includes(:form_elements).find(@params[:form_id])
  end

  def valid?
    errors.empty?
  end

  def errors
    form.form_elements.inject({}) do |errors, element|
      validate_field(element, errors)
    end
  end

  def validate_field(form_element, errors)
    el_name = form_element.name.to_sym
    errors[el_name] ||= []

    validate_required( form_element, el_name, errors)
    validate_country(  form_element, el_name, errors)
    validate_phone(    form_element, el_name, errors)
    validate_email(    form_element, el_name, errors)
    validate_zip(      form_element, el_name, errors)

    errors.delete(el_name) if errors[el_name].empty?
    errors
  end

  private

  def validate_required(form_element, el_name, errors)
    if form_element.required? && @params[el_name].blank?
      errors[el_name] << I18n.t("validation.is_required")
    end
  end

  def validate_phone(form_element, el_name, errors)
    phone_number = @params[el_name]
    if form_element.data_type == "phone" && phone_number.present? && !is_phone(phone_number)
      errors[el_name] << I18n.t("validation.is_invalid_phone")
    end
  end

  def validate_email(form_element, el_name, errors)
    email = @params[el_name]
    if form_element.data_type == "email" && email.present? && !is_email(email)
      errors[el_name] << I18n.t("validation.is_invalid_email")
    end
  end

  def validate_country(form_element, el_name, errors)
    country = @params[el_name]
    if form_element.data_type == "country" && country.present? && !is_country_code(country)
      errors[el_name] << I18n.t("validation.is_invalid_country")
    end
  end

  def validate_zip(form_element, el_name, errors)
    zip = @params[el_name]
    country = @params.fetch(:country, :US)
    if country.respond_to? :to_sym
      country = country.to_sym
    else
      # country is likely to be nil, so set it to our default
      country = :US
    end
    if form_element.data_type == 'zip' && zip.present? && !is_zip(zip, country)
      errors[el_name] << I18n.t("validation.is_invalid_zip")
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

  def is_zip(candidate, country)
    PostalValidator.valid?(candidate, country_code: country)
  end
end
