# frozen_string_literal: true
class DefaultFormBuilder
  class << self
    def find_or_create(locale: 'en')
      @locale = locale
      form = Form.masters.find_or_initialize_by(name: default_name)

      return form unless form.new_record?

      build_fields(form)
    end

    private

    def default_name
      "#{Form::DEFAULT_NAME} (#{@locale.upcase})"
    end

    def build_fields(form)
      fields(form).each do |field|
        FormElement.create!(field)
      end

      form
    end

    def fields(form)
      Form::DEFAULT_FIELDS.map do |field|
        translated = I18n.t(field[:label], locale: @locale)
        field.merge(form: form, label: translated)
      end
    end
  end
end
