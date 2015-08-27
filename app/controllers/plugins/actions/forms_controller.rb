class Plugins::Actions::FormsController < ApplicationController

  def create
    form = Form.find params[:form_id]
    action = Plugins::Action.find params[:action_id]
    new_form  = NewFormTemplateForPlugin.create(form, action)

    respond_to do |format|
      format.json do
        html = render_to_string(partial: 'forms/edit', locals: {form: new_form}, formats: [:html])
        render json: { html: html, form_id: new_form.id }
      end
    end
  end


  def update
    @plugin = Plugins::Action.find(params[:id])
    @plugin.update_attributes(permitted_params)
    @campaign_page = @plugin.campaign_page

    respond_to do |format|
      format.html { render 'plugins/show' }
      format.json { render json: action, status: :ok }
    end
  end

  private

  def find_form
    if params[:plugins_action][:form_id]
      Form.find params[:plugins_action][:form_id]
    end
  end

  def permitted_params
    params.require(:form).
      permit(:form_id, :active)
  end
end

