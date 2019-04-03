module HasPhoneNumber
  def validate_phone_number(*attrs)
    attrs.each do |attr|
      validate do
        errors.add(attr, 'is an invalid number') if send(attr).present? && !Phony.plausible?(send(attr))
      end
    end
  end

  def normalize_phone_number(*attrs)
    attrs.each do |attr|
      define_method("#{attr}=") do |number|
        new_value = begin
          number && "+#{Phony.normalize(number.to_s)}"
                    rescue Phony::NormalizationError
                      number
        end
        instance_variable_set("@#{attr}", new_value)
      end
    end
  end
end
