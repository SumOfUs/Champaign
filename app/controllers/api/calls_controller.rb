# frozen_string_literal: true

class Api::CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def create
    success = verify_recaptcha(action: params[:recaptcha_action], minimum_score: 0.5)

    if success
      service = CallCreator.new(call_params, tracking_params)

      if service.run
        head :no_content
      else
        render json: { errors: service.errors, name: 'call' }, status: :unprocessable_entity
      end
    else
      error = [
        {
          recaptcha: I18n.t('call_tool.errors.recaptcha_fail')
        }
      ]
      render json: { errors: error, name: 'call' }, status: :unprocessable_entity
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
    params.to_unsafe_hash
      .slice(:source, :akid, :referring_akid, :referrer_id, :rid)
      .merge(mobile_value)
  end
end
