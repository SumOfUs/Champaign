class FormElementsController < ApplicationController
  before_filter :find_form, only: [:create, :sort]

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

  def sort
    ids = params[:form_element_ids].split(',')
    ids.each_with_index do |id, index|
      FormElement.where(id: id, form_id: @form.id).update_all(position: index)
    end

    render json: @form.form_elements.map(&:position)
  end


  private

  def permitted_params
    params.require(:form_element).permit(:label, :data_type, :required)
  end

  def find_form
    @form = Form.find params[:form_id]
  end
end
