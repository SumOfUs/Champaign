# frozen_string_literal: true

module MemberServices
  class MemberUpdater
    attr_reader :member
    delegate :errors, to: :member

    def initialize(email, params)
      @email = email
      @params = params
    end

    def run
      @member = Member.find_by_email(@email)

      raise ActiveRecord::RecordNotFound unless @member

      @member.update(@params)
    end
  end
end
