class ActionValidator

  def initialize(params)
    @params = params
  end

  def form
    @form ||= Form.find(@params[:form_id]).includes(:form_elements)
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
    if form_element.required == true
      if !@params.has_key(form_element.name.to_sym) || @params[form_element.name.to_sym].blank?
        return [form_element.name, "is required"]
      end
    end
    if form_element.data_type == "email" && !is_email(@params[form_element.name.to_sym])
      return [form_element.name, "must be a valid email"]
    end
  end

  def is_email
    true
  end
end
