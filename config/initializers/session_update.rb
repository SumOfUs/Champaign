require 'rack/session/abstract/id' # defeat autoloading
module ActionDispatch
  class Request
    class Session # :nodoc:
      def changed?
        @changed
      end

      def load_for_write!
        load! unless loaded?
        @changed = true
      end
    end
  end
end

module Rack
  module Session
    module Abstract
      class Persisted
        private

        def commit_session?(req, session, options)
          if options[:skip]
            false
          else
            has_session = session.changed? || forced_session_update?(session, options)
            has_session && security_matches?(req, options)
          end
        end
      end
    end
  end
end
