module CallTool
  class CallStatusUpdater
    class << self
      def start!(call)
        return unless call.unstarted?
        call.started!
        CallEvent::Update.publish(call) if call.member.present?
      end

      def connect!(call)
        return unless call.started?
        call.connected!
        CallEvent::Update.publish(call) if call.member.present?
      end

      def update!(call, params)
        call.update!(params)
        CallEvent::Update.publish(call) if call.member.present?
      end

      def new_member_call_event!(call, params)
        call.member_call_events << params
        call.save!
        CallEvent::Update.publish(call) if call.member.present?
      end
    end
  end
end
