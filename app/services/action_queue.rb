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
      ( ISO3166::Country.search(iso_code).try(:translations) || {} )['en']
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

  module Donatable
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

    def data
      @action.form_data.symbolize_keys
    end

    def extra_fields_for_subscription
      {}.tap do |action|
        if @action.form_data['is_subscription']
          action[:skip_confirmation] = 1 if @action.form_data['recurrence_number'].to_i > 0
          action[:fields] = action_fields
        end
      end
    end
  end

  class Pusher
    def self.push(action)
      if action.donation
        if action.form_data.fetch('payment_provider', '').inquiry.go_cardless?
          DirectDebitAction.push(action)
        else
          DonationAction.push(action)
        end
      else
        PetitionAction.push(action)
      end
    end
  end

  class PetitionAction
    include Donatable
    include Enqueable

    def get_page_name
      if page.status.inquiry.imported?
        page.slug
      else
        "#{page.slug}-petition"
      end
    end

    def payload
      {
        type: 'action',
        params: {
          page: get_page_name,
        }.merge(@action.form_data).
          merge( UserLanguageISO.for(page.language) ).tap do |params|
            params[:country] = country(member.country) if member.country.present?
          end
      }.deep_symbolize_keys
    end
  end

  class DirectDebitAction
    include Enqueable
    include Donatable


    def payload
      if data[:is_subscription]
        subscription_payload
      else
        transaction_payload
      end
    end

    def subscription_payload
      {
        type:  'donation-subscription',
        payment_provider: 'go_cardless',
        params: {
          donationpage: {
            name:             "#{@action.page.slug}-donation",
            payment_account:  get_payment_account
          },
          order: {
            amount:       data[:amount],
            currency:     data[:currency],
            recurring_id: data[:subscription_id]
          },
          action: {
            source: data[:source]
          },
          user: user_data
        }
      }
    end

    def transaction_payload
      {
        type:  'donation-transaction',
        payment_provider: 'go_cardless',
        params: {
          donationpage: {
            name:             "#{@action.page.slug}-donation",
            payment_account:  get_payment_account
          },
          order: {
            amount:       data[:amount],
            currency:     data[:currency]
          },
          action: {
            source: data[:source]
          },
          user: user_data
        }
      }
    end

    def get_payment_account
      "GoCardless #{data[:currency]}"
    end

    def action_fields
      {
        recurring_id:      @action.member_id,
        recurrence_number: @action.form_data['recurrence_number'],
        payment_provider:  @action.form_data['payment_provider'],
      }
    end
  end

  class DonationAction
    include Enqueable
    include Donatable

    def payload
      if data[:is_subscription]
        subscription_payload
      else
        transaction_payload
      end
    end

    def subscription_payload
      {
        type:  'donation-subscription',
        payment_provider: 'braintree',
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
            currency:       data[:currency],
            recurring_id:   data[:subscription_id]
          },
          action: {
            source: data[:source]
          },
          user: user_data
        }
      }
    end


    def transaction_payload
      {
        type:  'donation-transaction',
        payment_provider: 'braintree',
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

    def action_fields
      {
        recurring_id:      @action.member_id,
        recurrence_number: @action.form_data['recurrence_number'],
        payment_provider:  @action.form_data['payment_provider'],
        exp_date:          "#{expire_month}#{expire_year.to_s.gsub(/^(\d\d)(\d\d)/,'\2')}"
      }
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

    def expire_month
      split_expire_date[0]
    end

    def expire_year
      split_expire_date[1]
    end

    def split_expire_date
      if data[:card_expiration_date] == '/' || data[:card_expiration_date].blank?
        # We weren't given an expiration, probably because it's a PayPal transaction, so set a fake expiration five years
        # in the future.
        [Time.now.month.to_s, (Time.now.year + 5).to_s]
      else
        @split_date ||= data[:card_expiration_date].split('/')
      end
    end
  end
end

