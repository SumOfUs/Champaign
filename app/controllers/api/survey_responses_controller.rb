class Api::SurveyResponsesController < ApplicationController
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
    params.require(:survey_response).permit(
      form.form_elements.map(&:name) + %w{form_id}
    )
  end

  def form
    @form ||= begin
      survey = Plugins::Survey.find_by(page_id: params[:page_id])
      survey.forms.includes(:form_elements).find(params[:survey_response][:form_id])
    end
  end

  def page
    @page ||= Page.find(params[:page_id])
  end
end
