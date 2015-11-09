class LiquidHelper
  class << self

    # when possible, I think we should try to make this match with
    # helpers in liquid docs to be more intuitive for people familiar with liquid
    # https://docs.shopify.com/themes/liquid-documentation/objects
    def globals(country: nil, member: nil)
      {
        country_option_tags: country_option_tags(country),
        member: member_hash(member)
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
      values[:postal] = values[:postal_code]
      values
    end
  end
end
