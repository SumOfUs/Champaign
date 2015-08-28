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
end

