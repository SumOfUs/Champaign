# frozen_string_literal: true
module AuthStub
  def current_user
    @current_user ||= FactoryGirl.create :user
  end

  def logged_in?
    true
  end
end
