class I18n::TranslationMissing < Exception; end

module LiquidI18nRails
  def t(string)
    return I18n.t(string) unless Rails.env.development? || Rails.env.test?
    begin
      I18n.t(string, :raise => true)
    rescue I18n::MissingTranslationData => e
      raise I18n::TranslationMissing.new(e.message)
    end
  end
end
