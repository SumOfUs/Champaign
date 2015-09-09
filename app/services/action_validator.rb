class ActionValidator

  def initialize(params)
    @params = params
  end

  def form
    @form ||= Form.includes(:form_elements).find(@params[:form_id])
  end

  def valid?
    errors.empty?
  end

  def errors
    form.form_elements.inject([]) do |errors, element|
      error = validate_field(element)
      error.nil? ? errors : errors << error
    end
  end

  def validate_field(form_element)
    key = form_element.name.to_sym
    if form_element.required? && @params[key].blank?
      return [form_element.name, "is required"]
    end
    if is_invalid_email(form_element, @params[key])
      return [form_element.name, "must be a valid email"]
    end
  end

  private

  def is_invalid_email(element, email)
    element.data_type == "email" && email.present? && !is_email(email)
  end

  def is_email(candidate)
    (/\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\z/i =~ candidate).present?
  end
end
