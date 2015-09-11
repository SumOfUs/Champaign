class LiquidHelper
  class << self

    # when possible, I think we should try to make this match with
    # helpers in liquid docs to be more intuitive for people familiar with liquid
    # https://docs.shopify.com/themes/liquid-documentation/objects
    def globals
      {
        'country_option_tags' => country_option_tags
      }
    end

    def country_option_tags
      options = []
      names_with_codes = ISO3166::Country.all_names_with_codes(I18n.locale.to_s)
      preferred(names_with_codes).each do |name, code|
        options << "<option value='#{code}'>#{name}</option>"
      end
      options.join("\n")
    end

    private

    def preferred(names_with_codes)
      codes = ['US', 'GB', 'CA', 'FR', 'DE']
      preferred = names_with_codes.select{|name, code| codes.include? code }
      preferred << ['--------', '']
      preferred + names_with_codes # better ux to have it twice than hard to find
    end
  end
end
