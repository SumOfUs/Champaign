class Api::DonationsController < ApplicationController
  respond_to :json

  # Fetches the sum of all donations (one off and recurring) for a given date range
  # If a date range is not provided, it will default to donations in the current
  # calendar month
  def total
    params.permit(:start, :end)
    start_date = params.fetch(:start, Date.today.beginning_of_month).to_date
    end_date = params.fetch(:end, Date.today.end_of_month).to_date

    raise ArgumentError, 'Invalid date range' if start_date > end_date

    response = {
      meta: { start: start_date.to_s, end: end_date.to_s },
      data: {
        total_donations: TransactionService.totals(start_date...end_date)
      }
    }
    respond_with response
  rescue ArgumentError
    head :bad_request
  end
end
