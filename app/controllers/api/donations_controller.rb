class Api::DonationsController < ApplicationController
  # Fetches the sum of all donations (one off and recurring) for a given date range
  # If a date range is not provided, it will default to donations in the current
  # calendar month
  #
  # This endpoint is only used for the EOY donations thermometer. That's why the data includes also a hash of
  # EOY donations goals in different currencies, rounded around the base goal of 600000 USD.
  def total
    params.permit(:start, :end)
    start_date = params.fetch(:start, Date.today.beginning_of_month).to_date
    end_date = params.fetch(:end, Date.today.end_of_month).to_date

    raise ArgumentError, 'Invalid date range' if start_date > end_date

    response = {
      meta: { start: start_date.to_s, end: end_date.to_s },
      data: {
        total_donations: TransactionService.totals(start_date...end_date),
        eoy_goals: TransactionService.goals(50_000_000)
      }
    }

    render json: response
  rescue ArgumentError
    head :bad_request
  end
end
