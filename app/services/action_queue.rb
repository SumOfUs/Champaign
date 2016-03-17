require 'active_support/concern'

module ActionQueue
  module Enqueable
    extend ActiveSupport::Concern

    def initialize(action)
      @action = action
    end

    def push
      ChampaignQueue.push(payload)
    end

    def page
      @page ||= @action.page
    end

    def country(iso_code)
      # ActionKit uses some country names which don't match up to their official
      # ISO names. So, we need to do some replacement on those names.
      names_to_replace = {
          "Bolivia, Plurinational State of" => 'Bolivia',
          "Iran, Islamic Republic Of" => 'Iran',
          "Korea, Republic of" => 'South Korea',
          "Korea, Democratic People's Republic Of" => 'North Korea',
          "Lao People's Democratic Republic" => 'Laos',
          "Macao" => 'Macau',
          "Macedonia, the Former Yugoslav Republic Of" => 'Macedonia',
          "Micronesia, Federated States Of" => 'Micronesia',
          "Moldova, Republic of" => 'Moldova',
          "Palestine, State of" => 'Palestine',
          "Russian Federation" => 'Russia',
          "Saint Martin (French part)" => 'Saint Martin',
          "Sint Maarten (Dutch part)" => 'Sint Maarten',
          "Syrian Arab Republic" => 'Syria',
          "Tanzania, United Republic of" => 'Tanzania',
          "Venezuela, Bolivarian Republic of" => 'Venezuela'
      }

      country_name = ISO3166::Country.find_country_by_alpha2(iso_code).try(:name)
      if names_to_replace.has_key?(country_name)
        country_name = names_to_replace[country_name]
      end

      country_name
    end

    def member
      @member ||= @action.member
    end

    class_methods do
      def push(action)
        new(action).push
      end
    end
  end

  class Pusher
    def self.push(action)
      action.donation? ? DonationAction.push(action) : PetitionAction.push(action)
    end
  end

  class PetitionAction
    include Enqueable

    def payload
      {
        type: 'action',
        params: {
          page: "#{@action.page.slug}-petition"
        }.merge(@action.form_data).
          merge( UserLanguageISO.for(page.language) ).tap do |params|
            params[:country] = country(member.country) if member.country.present?
          end
      }.deep_symbolize_keys
    end
  end

  class DonationAction
    include Enqueable

    def payload
      {
        type:  'donation',
        params: {
          donationpage: {
            name:             "#{@action.page.slug}-donation",
            payment_account:  get_payment_account
          },
          order: {
            amount:         data[:amount],
            card_num:       data[:card_num],
            card_code:      '007',
            exp_date_month: expire_month,
            exp_date_year:  expire_year,
            currency:       data[:currency]
          },
          action: {
            source: data[:source]
          },
          user: user_data
        }
      }
    end

    def user_data
      {
          first_name: member.first_name,
          last_name:  member.last_name,
          email:      member.email,
          country:    country(member.country),
          akid:       data[:akid],
          postal:     data[:postal],
          address1:   data[:address1],
          source:     data[:source]
      }.merge(UserLanguageISO.for(page.language) )
    end

    # ActionKit can accept one of the following:
    #
    # PayPal USD
    # PayPal GBP
    # PayPal CAD
    # PayPal EUR
    # PayPal AUD
    #
    # Braintree USD
    # Braintree CAD
    # Braintree AUD
    # Braintree GBP
    # Braintree EUR
    #
    def get_payment_account
      provider = is_paypal? ? 'PayPal' : 'Braintree'
      "#{provider} #{data[:currency]}"
    end

    def is_paypal?
      data[:card_num] == "PYPL"
    end

    def data
      @action.form_data.symbolize_keys
    end

    def expire_month
      split_expire_date[0]
    end

    def expire_year
      split_expire_date[1]
    end

    def split_expire_date
      if data[:card_expiration_date] == '/'
        # We weren't given an expiration, probably because it's a PayPal transaction, so set a fake expiration five years
        # in the future.
        [Time.now.month.to_s, (Time.now.year + 5).to_s]
      else
        @split_date ||= data[:card_expiration_date].split('/')
      end
    end
  end
end

