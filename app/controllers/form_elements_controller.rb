class FormElementsController < ApplicationController
  before_filter :find_form, only: [:create, :destroy]

  def create
    @element = @form.form_elements.create(permitted_params)

    respond_to do |format|
      format.html do
        render partial: 'element', locals: { form: @form, element: @element }, status: :ok
      end
    end
  end

  def destroy
    element = @form.form_elements.find(params[:id])
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
