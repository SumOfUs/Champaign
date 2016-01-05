class DefaultFormBuilder
  FIELDS = [
    { label: 'Email Address',  name: 'email',  required: true,  data_type: 'email'},
    { label: 'Full Name',      name: 'name',   required: true,  data_type: 'text' },
    { label: 'Postal Code',    name: 'postal', required: false, data_type: 'text' }
  ]

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
      FIELDS.map{|field| field.merge(form: form)}
    end
  end
end

