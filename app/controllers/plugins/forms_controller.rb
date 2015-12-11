class Plugins::FormsController < ApplicationController

  def create
    master = Form.find params[:master_id]
    plugin = Plugins.find_for params[:plugin_type], params[:plugin_id]
    new_form = attach_duplicate_form(master, plugin)

    respond_to do |format|
      format.json do
        html = render_to_string(partial: 'forms/edit', locals: {form: new_form}, formats: [:html])
        render json: { html: html, form_id: new_form.id }
      end
    end
  end

  def show
    plugin = Plugins.find_for params[:plugin_type], params[:plugin_id]
    render partial: 'plugins/shared/preview', locals: { plugin: plugin }
  end


  private

  def attach_duplicate_form(form, plugin)
    new_form = FormDuplicator.duplicate(form)
    plugin.update form: new_form
    new_form
  end

end

