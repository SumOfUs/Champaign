class Plugins::PetitionsController < ApplicationController
  before_filter :find_form

  def update
    @plugin = Plugins::Petition.find(params[:id])
    @plugin.update_attributes(permitted_params)
    @page = @plugin.page

    respond_to do |format|
      format.js   { render nothing: true }
      format.html { render 'plugins/show' }
      format.json { render json: @plugin, status: :ok }
    end
  end

  private

  def find_form
    if params[:plugins_petition][:form_id]
      Form.find params[:plugins_petition][:form_id]
    end
  end

  def permitted_params
    params.require(:plugins_petition).
      permit(:description, :active, :target, :cta)
  end
end
