# frozen_string_literal: true

class ActionParamsBuilder
  attr_reader :controller, :params

  delegate :browser, :request, to: :controller

  def initialize(controller, params)
    @controller = controller
    @params = params
  end

  def action_params
    build_params
  end

  private

  def mobile_value
    MobileDetector.detect(browser)
  end

  def referer_url
    { action_referer: request.referer }
  end

  def build_params
    params.permit(fields + base_params).merge(donation: true)
  end

  def base_params
    %w(page_id form_id name source akid referring_akid email)
  end

  def fields
    form = Form.find_by(id: params[:form_id])

    if form
      form.form_elements.map(&:name)
    else
      []
    end
  end
end
