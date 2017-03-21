# frozen_string_literal: true
class Api::PensionFundsController < ApplicationController
  def index
    funds = File.read("spec/fixtures/pension_funds/#{params[:country]}.json")
    #funds = JSON.parse(funds)
    #funds = funds.map{|fund| {value:fund['name'], label:fund['name']} }
    render json: funds
  end
end
