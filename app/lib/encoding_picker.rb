class EncodingPicker
  def self.pick(string)
    if string.force_encoding(Encoding::UTF_8).valid_encoding?
      Encoding::UTF_8
    else
      Encoding::ISO_8859_15
    end
  end
end
