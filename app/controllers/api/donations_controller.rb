class Api::DonationsController < ApplicationController
  respond_to :json

  def total
    params.permit(:start, :end)
    start_date = params.fetch(:start, Date.today.beginning_of_month).to_date
    end_date = params.fetch(:end, Date.today.end_of_month).to_date
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
