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
        }.merge(@action.form_data)
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
          country:    member.country,
          akid:       data[:akid],
          postal:     data[:postal],
          address1:   data[:address1],
          source:     data[:source]
      }
    end

    def member
      @member ||= @action.member
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

