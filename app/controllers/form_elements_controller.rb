class FormElementsController < ApplicationController
  def create
    @form = Form.find params[:form_id]
    @element = @form.form_elements.create(permitted_params)

    respond_to do |format|
      format.html do
        render partial: 'element', locals: { element: @element }, status: :ok
      end
    end
  end


  private

  def permitted_params
    params.require(:form_element).permit(:label, :name, :data_type, :required)
  end
end
