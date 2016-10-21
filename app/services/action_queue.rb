# frozen_string_literal: true
require 'active_support/concern'

module ActionQueue
  module Enqueable
    extend ActiveSupport::Concern

    def initialize(action)
      @action = action
    end

    def push
      ChampaignQueue.push(payload.merge(meta))
    end

    def page
      @page ||= @action.page
    end

    def data
      @action.form_data.symbolize_keys
    end

    def country(iso_code)
      (ISO3166::Country.search(iso_code).try(:translations) || {})['en']
    end

    def member
      @member ||= @action.member
    end

    def meta
      {
        meta: {
          title:      page.title,
          uri:        "/a/#{page.slug}",
          slug:       page.slug,
          first_name: member.first_name,
          last_name:  member.last_name,
          created_at: @action.created_at,
          country:    country(member.country),
          action_id:  @action.id,
          subscribed_member: @action.subscribed_member
        }
      }
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
        source:     data[:source],
        user_express_cookie: data[:store_in_vault] ? 1 : 0,
        user_express_account: data[:express_account] ? 1 : 0
      }.merge(UserLanguageISO.for(page.language))
    end

    def action_fields
      @action_fields ||= {}.tap do |fields|
        data.keys.select { |k| k =~ /^action_/ }.each do |key|
          fields[key] = data[key]
        end
        fields[:action_bucket] = data[:bucket] if data.key? :bucket
      end
    end
  end

  class Pusher
    def self.push(event, action)
      case event
      when :new_action
        if action.donation
          if action.form_data.fetch('payment_provider', '').inquiry.go_cardless?
            NewDirectDebitAction.push(action)
          else
            NewDonationAction.push(action)
          end
        else
          NewPetitionAction.push(action)
        end
      when :new_survey_response
        NewSurveyResponse.push(action)
      end
    end
  end

  class NewPetitionAction
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
          email: @action.member.email
        }.merge(@action.form_data)
          .merge(UserLanguageISO.for(page.language))
          .tap do |params|
            params[:country] = country(member.country) if member.country.present?
            params[:action_bucket] = data[:bucket] if data.key? :bucket
          end
      }.deep_symbolize_keys
    end
  end

  class NewSurveyResponse < NewPetitionAction
    def payload
      super.tap do |p|
        p[:type] = 'new_survey_response'
        p[:params][:fields] = @action.form_data
      end
    end
  end

  class NewDirectDebitAction
    include Enqueable
    include Donatable

    def payload
      # TODO: This really needs to be handled in a less hackish solution once we refactor.
      @action.form_data[:action_express_donation] = 0
      if data[:is_subscription]
        subscription_payload
      else
        transaction_payload
      end
    end

    def subscription_payload
      {
        type:  'donation',
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
          }.merge(fake_card_info),
          action: action_data,
          user: user_data
        }
      }
    end

    def transaction_payload
      {
        type:  'donation',
        payment_provider: 'go_cardless',
        params: {
          donationpage: {
            name:             "#{@action.page.slug}-donation",
            payment_account:  get_payment_account
          },
          order: {
            amount:       data[:amount],
            currency:     data[:currency]
          }.merge(fake_card_info),
          action: action_data,
          user: user_data
        }
      }
    end

    def action_data
      {
        fields: action_fields.merge(
          action_account_number_ending:  data[:account_number_ending],
          action_mandate_reference:      data[:mandate_reference],
          action_bank_name:              data[:bank_name],
          action_express_donation:       data[:express_donation] ? 1 : 0
        ),
        source: data[:source]
      }
    end

    def fake_card_info
      {
        card_num:       'DDEB',
        card_code:      '007',
        exp_date_month: '01',
        exp_date_year:  '99'
      }
    end

    def get_payment_account
      "GoCardless #{data[:currency]}"
    end

    def user_data
      super.except(:user_express_cookie, :user_express_account)
    end
  end

  class NewDonationAction
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
        type:  'donation',
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
            source: data[:source],
            fields: action_fields
          },
          user: user_data
        }
      }
    end

    def transaction_payload
      {
        type:  'donation',
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
            source: data[:source],
            fields: action_fields
          },
          user: user_data
        }
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
      data[:card_num] == 'PYPL'
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
