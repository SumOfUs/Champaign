module CallEvent
  class Base
    def self.publish(call)
      new(call).publish
    end

    def initialize(call)
      @call = call
    end

    def publish
      ChampaignQueue.push(payload)
    end

    private

    def payload
      {
        params: {
          page: "#{@call.page.slug}-petition",
          email: @call.member.email,
          phone: @call.member_phone_number,
          action_call_status: @call.status,
          action_target_call_status: @call.target_call_status,
          action_target: @call.target.to_hash
        },
        meta: { call_id: @call.id }
      }
    end
  end

  class New < Base
    def payload
      super.tap do |p|
        p[:type] = 'new_call'
      end
    end
  end

  class Update < Base
    def payload
      super.tap do |p|
        p[:type] = 'update_call'
      end
    end
  end
end
