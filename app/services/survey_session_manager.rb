# frozen_string_literal: true
class SurveySessionManager
  def initialize(session)
    @session = session
  end

  def [](page_id)
    page_action_map[page_id.to_s]
  end

  def []=(page_id, action_id)
    page_action_map[page_id.to_s] = action_id
    update
  end

  private

  def page_action_map
    @page_action_map ||= begin
      if @session[:survey_action_token].present?
        JWT.decode(@session[:survey_action_token], Settings.secret_key_base).first
      else
        {}
      end
    end
  end

  def update
    @session[:survey_action_token] = JWT.encode(page_action_map, Settings.secret_key_base)
  end
end
