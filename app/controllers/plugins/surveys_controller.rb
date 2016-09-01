# frozen_string_literal: true
class Plugins::SurveysController < Plugins::BaseController

  def add_form
    plugin = Plugins.find_for('survey', params[:plugin_id])
    @form = Form.new(name: "survey_form_#{params[:plugin_id]}", master: false, formable: plugin)

    respond_to do |format|
      if @form.save
        puts "\n\nwhyyyy\n\n",@form
        format.js { render :add_form }
      else
        format.js { render json: { errors: @form.errors }, status: :unprocessable_entity }
      end
    end
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
