# frozen_string_literal: true

module ApplicationHelper
  def location
    @location = request.location.data
    return @location if @location.blank?

    if @recognized_member.try(:country) && @recognized_member.country.length == 2
      @location[:country_code] = @recognized_member.country
    end

    @location[:country] = @location[:country_code]
    @location[:currency] = Donations::Utils.currency_from_country_code(@location[:country_code])
    @location
  end
end
