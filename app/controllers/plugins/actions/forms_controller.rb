class NewFormTemplateForPlugin
  def self.create(form, plugin)
    plugin.update form: FormDuplicator.duplicate(form)
  end
end

class Plugins::Actions::FormsController < ApplicationController

  def create
    form = Form.find params[:form_id]
    action = Plugins::Action.find params[:action_id]
    NewFormTemplateForPlugin.create(form, action)

    render json: {'yes' => :foo}
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

