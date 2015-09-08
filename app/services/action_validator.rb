class ActionValidator

  def initialize(params)
    @params = params
  end

  def form
    @form ||= Form.includes(:form_elements).find(@params[:form_id])
  end

  def valid?
    errors.size == 0
  end

  def errors
    errors = []
    form.form_elements.each do |element|
      error = validate_field(element)
      errors.push(error) unless error.nil?
    end
    errors
  end

  def validate_field(form_element)
    key = form_element.name.to_sym
    if form_element.required == true
      if !@params.has_key?(key) || @params[key].blank?
        return [form_element.name, "is required"]
      end
    end
    if form_element.data_type == "email" && @params[key].present? && !is_email(@params[key])
      return [form_element.name, "must be a valid email"]
    end
  end

  def is_email(candidate)
    (/\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\z/i =~ candidate).present?
  end
end
