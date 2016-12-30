class Api::CallsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    call = CallCreator.run(call_params)

    if call.persisted?
      head 200
    else
      render json: { errors: call.errors }, status: :unprocessable_entity
    end
  end

  private

  def call_params
    params.require(:call).permit(:phone, :target_id)
      .merge(page_id: params[:page_id])
      .merge(member_id: recognized_member&.id)
  end

end
