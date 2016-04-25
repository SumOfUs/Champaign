module PaymentProcessor
  module GoCardless
    class ErrorProcessing

      def initialize(errors)
        @errors = errors
      end

      def process
        @errors
        # return user_errors if user_errors.any?
        # return processor_errors if processor_errors.any?

        # raise_system_errors if system_errors.any?
      end

      private

    end
  end
end

