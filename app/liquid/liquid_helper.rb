class LiquidHelper
  # TODO: Move constants to `Donations`
  EURO_COUNTRY_CODES = [:AL, :AD, :AT, :BY, :BE, :BA, :BG, :HR, :CY, :CZ, :DK, :EE, :FO, :FI, :FR, :DE, :GI, :GR, :HU, :IS, :IE, :IT, :LV, :LI, :LT, :LU, :MK, :MT, :MD, :MC, :NL, :NO, :PL, :PT, :RO, :RU, :SM, :RS, :SK, :SI, :ES, :SE, :CH, :UA, :VA, :RS, :IM, :RS, :ME]
  DEFAULT_CURRENCY = 'USD'

  class << self

    # when possible, I think we should try to make this match with
    # helpers in liquid docs to be more intuitive for people familiar with liquid
    # https://docs.shopify.com/themes/liquid-documentation/objects
    def globals(request_country: nil, member: nil, page: nil)
      {
        country_option_tags: country_option_tags(selected_country(request_country, member)),
        member: member_hash(member),
        petition_target: petition_target(page),
        guessed_currency: guess_currency(request_country)
      }
    end

    def country_option_tags(user_country_code=nil)
      options = []
      names_with_codes = ISO3166::Country.all_names_with_codes(I18n.locale.to_s)
      names_with_codes.each do |name, code|
        selected = (user_country_code == code) ? "selected='selected'" : ""
        options << "<option value='#{code}' #{selected}>#{name}</option>"
      end
      options.join("\n")
    end

    def petition_target(page)
      return nil unless page.present?
      actions = page.plugins.select{ |p| p.name == "Petition" && p.active? }
      actions.map(&:target).reject(&:blank?).first
    end

    # TODO: 'Country code to currency' probably better served by +Donations::Utils+
    def guess_currency(request_country)
      return 'EUR' if EURO_COUNTRY_CODES.include?(request_country.try(:to_sym))

      {
        US: 'USD',
        GB: 'GBP',
        NZ: 'NZD',
        AU: 'AUD',
        CA: 'CAD'
      }[request_country.try(:to_sym)] || DEFAULT_CURRENCY
    end

    private

    def preferred(names_with_codes)
      # currently unused
      codes = ['US', 'GB', 'CA', 'FR', 'DE']
      preferred = names_with_codes.select{|name, code| codes.include? code }
      preferred + names_with_codes # better ux to have it twice than hard to find
    end

    def member_hash(member)
      return nil if member.blank?
      values = member.attributes.symbolize_keys
      values[:welcome_name] = [values[:first_name], values[:last_name]].join(' ')
      values[:welcome_name] = values[:email] if values[:welcome_name].blank?
      values
    end

    def selected_country(request_country, member)
      #member.present? && member.country.present? ? member.country : request_country
    end
  end
end

