# frozen_string_literal: true

class Api::PensionFundsController < ApplicationController
  rescue_from Errno::ENOENT, with: :funds_not_found

  def index
    funds = File.read("spec/fixtures/pension_funds/#{params[:country]}.json")
    render json: funds
  end

  def suggest_fund
    name = params['email_target']['name']
    PensionFundSuggestion.create(name)
    head :ok
  end

  private

  def funds_not_found
    head 404
  end
end
