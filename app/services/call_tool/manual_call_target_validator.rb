class ManualCallTargetValidator
  class << self
    def validate(country_code, phone_number, checksum)
      return false if [country_code, phone_number, checksum].map(&:blank?).any?
      unhashed = "#{country_code}#{phone_number}#{Settings.calls.targeting_secret}"
      checksum == Digest::SHA256.hexdigest(unhashed)[0..5]
    end
  end
end
