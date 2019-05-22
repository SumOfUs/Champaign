# frozen_string_literal: true

module PaymentProcessor::Braintree
  class DuplicateDonationError < StandardError
    def message
      I18n.t('fundraiser.oneclick.duplicate_donation')
    end
  end
end
