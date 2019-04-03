# frozen_string_literal: true

class Api::SurveyResponsesController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :localize_from_page_id, only: :create

  def create
    service = ManageSurveyResponse.new(
      page: page, form: form, params: survey_response_params, action_id: session_manager[page.id]
    )

    if service.run
      session_manager[page.id] = service.action.id
      head :no_content
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def session_manager
    @session_manager ||= SurveySessionManager.new(session)
  end

  def survey_response_params
    params
      .to_unsafe_hash
      .slice(*form.form_elements.map(&:name), 'akid', 'source', 'referring_akid', 'rid', 'referrer_id')
  end

  def form
    @form ||= begin
      survey = Plugins::Survey.find_by(page_id: params[:page_id])
      survey.forms.includes(:form_elements).find(params[:form_id])
    end
  end

  def page
    @page ||= Page.find(params[:page_id])
  end
end
