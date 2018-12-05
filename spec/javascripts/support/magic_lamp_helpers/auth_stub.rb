# frozen_string_literal: true
module AuthStub
  def current_user
    @current_user ||= FactoryBot.create :user
  end

  def logged_in?
    true
  end
end
