class ManualCallTargetValidator
  class << self
    def validate(phone_number, checksum)
      return false if country_code.blank? || checksum.blank?
      unhashed = "#{phone_number}#{Settings.calls.targeting_secret}"
      checksum == Digest::SHA256.hexdigest(unhashed)[0..5]
    end
  end
end
