class FormElementsController < ApplicationController
  before_filter :find_form, only: [:create]

  def create
    @element = FormElementBuilder.create(@form, permitted_params)

    respond_to do |format|
      if @element.valid?
        format.html  { render partial: 'element', locals: { form: @form, element: @element }, status: :ok }
      else
        format.json { render json: @element.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    element = FormElement.find(params[:id])
    element.destroy

    respond_to do |format|
      format.json do
        render json: {status: :ok}, status: :ok
      end
    end
  end


  private

  def permitted_params
    params.require(:form_element).permit(:label, :name, :data_type, :required)
  end

  def find_form
    @form = Form.find params[:form_id]
  end
end
