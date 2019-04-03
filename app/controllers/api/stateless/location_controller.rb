# frozen_string_literal: true

module Api
  module Stateless
    class LocationController < StatelessController
      def index
        render json: { location: location_with_currency }
      rescue Api::Exceptions::LocationNotFound
        head 504
      end

      private

      def location
        @location ||= request.location
        raise Api::Exceptions::LocationNotFound unless @location

        @location.data
      end

      def location_with_currency
        @location_with_currency ||= location.merge(
          currency: Donations::Utils.currency_from_country_code(location['country_code'])
        )
      end
    end
  end
end
