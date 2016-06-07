module PaymentProcessor
  module GoCardless
    module Helper
      extend self

      # Returns the next date for the passed day.
      #
      # === Attributes
      #
      # *day+ - The day to set the date too.
      def next_available_date(day)
        date = Date.today.change(day: day)

        if Time.now.day >= day
          date += 1.month
        end

        date
      end
    end
  end
end

