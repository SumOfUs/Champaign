# frozen_string_literal: true

class DefaultFormBuilder
  DEFAULT_FIELDS = [
    { label: 'form.default.email',        name: 'email',   required: true,  data_type: 'email'   },
    { label: 'form.default.name',         name: 'name',    required: true,  data_type: 'text'    },
    { label: 'form.default.country',      name: 'country', required: true,  data_type: 'country' },
    { label: 'form.default.postal',       name: 'postal',  required: false, data_type: 'postal'  },
    { label: 'form.default.phone_number', name: 'phone_number',
      required: false, data_type: 'phone', display_mode: 'recognized_members_only' }
  ].freeze

  class << self
    def find_or_create(locale: 'en')
      @locale = locale
      form = Form.masters.find_or_initialize_by(name: default_name)

      return form unless form.new_record?

      build_fields(form)
    end

    private

    def default_name
      "Basic (#{@locale.upcase})"
    end

    def build_fields(form)
      fields(form).each do |field|
        FormElement.create!(field)
      end

      form
    end

    def fields(form)
      DEFAULT_FIELDS.map do |field|
        translated = I18n.t(field[:label], locale: @locale)
        field.merge(form: form, label: translated)
      end
    end
  end
end
