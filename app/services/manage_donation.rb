# frozen_string_literal: true

class ManageDonation
  include ActionBuilder

  def self.create(params:)
    new(params: params).create
  end

  def initialize(params:)
    @params = params
  end

  def create
    build_action(donation: true)
  end
end
