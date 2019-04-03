# frozen_string_literal: true

class LiquidHelper
  class << self
    # when possible, I think we should try to make this match with
    # helpers in liquid docs to be more intuitive for people familiar with liquid
    # https://docs.shopify.com/themes/liquid-documentation/objects
    def globals(page: nil)
      {
        country_option_tags: country_option_tags,
        petition_target: petition_target(page)
      }
    end

    def country_option_tags(user_country_code = nil)
      options = []
      names_with_codes = ISO3166::Country.all_names_with_codes(I18n.locale.to_s)
      names_with_codes.each do |name, code|
        selected = user_country_code == code ? "selected='selected'" : ''
        options << "<option value='#{code}' #{selected}>#{name}</option>"
      end
      options.join("\n")
    end

    def petition_target(page)
      return nil unless page.present?

      actions = page.plugins.select { |p| p.name == 'Petition' && p.active? }
      actions.map(&:target).reject(&:blank?).first
    end
  end
end
