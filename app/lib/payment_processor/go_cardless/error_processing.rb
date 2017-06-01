# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    class ErrorProcessing
      def initialize(error, locale: nil)
        @locale = locale || I18n.default_locale
        @error = error
      end

      def process
        @error
        case @error.type
        when 'gocardless'
          handle_gc_internal_error
        when 'invalid_api_usage'
          handle_api_usage_error
        when 'invalid_state'
          handle_state_error
        when 'validation_failed'
          handle_validation_error
        else
          # sometimes the GC ruby library doesn't use a documented
          # error class and gives a blank type (eg when request was
          # blocked by network provider) so in that case we want to
          # log the stack trace and take responsibility.
          handle_api_usage_error
        end
      end

      private

      # this type of error is returned when our code makes a malformed request, and
      # should be treated equivalently to an internal server on our part. However,
      # we're not raising so that the user completing the redirect flow does not
      # encounter our generic 500 page.
      def handle_api_usage_error
        log_error(@error.backtrace.slice(0, 3).join("\n"))
        [{ code: @error.code, message: I18n.t('fundraiser.unknown_error', locale: @locale) }]
      end

      # this type of error is returned when GC has a 500
      def handle_gc_internal_error
        log_error("#{@error.message}. Please report to GoCardless support staff.")
        [{ code: @error.code, message: I18n.t('fundraiser.unknown_error', locale: @locale) }]
      end

      # state error is generally a user error, such as a user trying to do something twice in
      # a row.
      def handle_state_error
        log_error("#{@error.message}. #{full_messsages(@error.errors)}")
        @error.errors.map { |e| { code: @error.code, message: e['message'] } }
      end

      # this is some kind of user error. we should show it to them and allow them to act on it
      def handle_validation_error
        log_error(full_messsages(@error.errors))
        @error.errors.map { |e| { code: @error.code, attribute: e['field'], message: full_message(e) } }
      end

      def full_messsages(errors)
        errors.map { |e| full_message(e) }.join('. ')
      end

      def full_message(error)
        error.key?('field') ? "#{error['field']} #{error['message']}" : error['message']
      end

      def log_error(message)
        Rails.logger.error "#{@error.class}: #{message} (request: #{@error.request_id})"
      end
    end
  end
end
