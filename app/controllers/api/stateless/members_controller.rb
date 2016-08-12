module Api
  module Stateless
    class MembersController < StatelessController
      before_filter :authenticate_request!

      def show
        @current_member
      end
    end
  end
end
