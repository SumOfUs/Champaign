# frozen_string_literal: true

class Plugins::FormsController < ApplicationController
  def create
    master = Form.find permitted_params[:master_id]
    plugin = Plugins.find_for permitted_params[:plugin_type], permitted_params[:plugin_id]
    new_form = attach_duplicate_form(master, plugin)

    respond_to do |format|
      format.json do
        html = render_to_string(partial: 'forms/edit', locals: { form: new_form }, formats: [:html])
        render json: { html: html, form_id: new_form.id }
      end
    end
  end

  def show
    plugin = Plugins.find_for permitted_params[:plugin_type], permitted_params[:plugin_id]
    partial_dir = plugin.name == 'Survey' ? 'surveys' : 'shared'
    render partial: "plugins/#{partial_dir}/preview", locals: { plugin: plugin }
  end

  private

  def attach_duplicate_form(form, plugin)
    new_form = FormDuplicator.duplicate(form)
    plugin.update_form(new_form)
    new_form
  end

  def permitted_params
    params.permit(:plugin_id, :plugin_type, :master_id)
  end
end
