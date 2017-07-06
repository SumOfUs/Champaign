module CallTool
  module CheckSumValidator
    def self.validate(number:, name:, checksum:, secret:)
      unhashed = "#{number}#{name}#{secret}"
      checksum == Digest::SHA256.hexdigest(unhashed)[0..5]
    end
  end
end
