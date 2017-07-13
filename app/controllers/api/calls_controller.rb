# frozen_string_literal: true

class Api::CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def create
    service = CallCreator.new(call_params, tracking_params)

    if service.run
      head :no_content
    else
      render json: { errors: service.errors, name: 'call' }, status: :unprocessable_entity
    end
  end

  private

  def call_params
    params.require(:call)
      .permit(:member_phone_number, :target_id, :target_title, :target_name,
              :target_phone_number, :target_phone_extension, :checksum)
      .merge(page_id: params[:page_id],
             member_id: recognized_member&.id)
  end

  def tracking_params
    params
      .slice('source', 'akid', 'referring_akid', 'referrer_id', 'rid', 'bucket')
      .to_unsafe_hash
  end
end
