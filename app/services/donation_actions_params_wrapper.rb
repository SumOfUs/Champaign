# frozen_string_literal: true

class DonationActionParamsWrapper
  def self.params(params)
    new(params).params
  end

  def initialize(params)
    @params = params
  end

  def params
    @params[:user].merge(
      page_id: @params[:page_id]
    )
  end
end
