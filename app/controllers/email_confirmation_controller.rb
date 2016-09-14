# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  def verify
    @errors = AuthTokenVerifier.verify(params)
    render :follow_up
  end
end
