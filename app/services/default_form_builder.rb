class DefaultFormBuilder
  class << self
    def create
      form = Form.masters.find_or_initialize_by(name: Form::DEFAULT_NAME)

      return form unless form.new_record?

      build_fields(form)
    end

    private

    def build_fields(form)
      fields(form).each do |field|
        FormElement.create!(field)
      end

      form
    end

    def fields(form)
      Form::DEFAULT_FIELDS.map{|field| field.merge(form: form)}
    end
  end
end

