# frozen_string_literal: true
class Plugins::SurveysController < Plugins::BaseController
  def add_form
    survey = Plugins.find_for('survey', params[:plugin_id])
    position = survey.forms.last.position + 1
    @form = Form.new(name: "survey_form_#{params[:plugin_id]}",
                     master: false,
                     formable: survey,
                     position: position)

    respond_to do |format|
      if @form.save
        format.js { render :add_form }
      else
        format.js { render json: { errors: @form.errors }, status: :unprocessable_entity }
      end
    end
  end

  def sort_forms
    ids = params[:form_ids].split(',')
    ids.each_with_index do |id, index|
      Form.where(id: id).first.update_attributes(position: index)
    end

    head :ok
  end

  private

  def permitted_params
    params
      .require(:plugins_survey)
      .permit(:active, :id)
  end

  def plugin_class
    Plugins::Survey
  end

  def plugin_symbol
    :plugins_survey
  end
end
