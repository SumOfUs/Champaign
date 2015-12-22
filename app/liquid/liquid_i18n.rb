# The <tt>LiquidI18nRails</tt> module allows us to use the +translate+
# method of Rails' I18n library within liquid templates. To use it,
# simply pass the name of the text entry to the +t+ filter:
#
#   {{ 'fundraiser.thank_you' | t }}
#
# The above tag is equivalent to calling:
#
#   I18n.t('fundraiser.thank_you')
#
# The only logic here serves to ensure aggressive reporting of missing
# translations when in development and test mode. In those environments,
# if a template is rendered and a translation is missing, an exception
# will be raised. In production, it will show a fallback message.
#
# Because +Liquid+ catches +StandardError+, we've created another error
# class subclassed directly on Exception that will not be caught.

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
