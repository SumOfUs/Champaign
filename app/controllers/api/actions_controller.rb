class Api::ActionsController < ApplicationController
  before_filter :localize_from_page_id

  def create
    @action_params = action_params
    validator = FormValidator.new(@action_params)

    if validator.valid?
      action = ManageAction.create(@action_params)

      Analytics.log({
        page: {
          title: page.title,
          id:    page.id
        },
        member: {
          full_name: action.member.full_name
        }
      })

      write_member_cookie(action.member_id)
      render json: {}, status: 200
    else
      render json: {errors: validator.errors}, status: 422
    end
  end

  def validate
    validator = FormValidator.new(action_params)
    if validator.valid?
      render json: {}, status: 200
    else
      render json: {errors: validator.errors}, status: 422
    end
  end

  private

  def action_params
    @action_params = params.
      permit( fields + base_params )
  end

  def base_params
    %w{page_id form_id name source akid referring_akid}
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end
end

