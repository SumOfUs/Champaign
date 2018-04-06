# frozen_string_literal: true

class Api::ConsentsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def create
    member = Member.find_by_id_and_email! params[:id], params[:email]
    member.update(consented_at: Time.now)
    render json: member
  end

  private

  def not_found
    render json: { error: 'No member was found.' }, status: 404
  end
end
