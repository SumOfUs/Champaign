# frozen_string_literal: true
class FormElementsController < ApplicationController
  before_filter :find_form, only: [:create, :sort]
  before_action :authenticate_user!

  def create
    @form_element = FormElementBuilder.create(@form, permitted_params)

    respond_to do |format|
      if @form_element.valid?
        format.html { render partial: 'element', locals: { form: @form, element: @form_element }, status: :ok }
      else
        format.html { render :new }
        format.js { render json: { errors: @form_element.errors, name: :form_element }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @form_element = FormElement.find(params[:id])
    @form_element.destroy

    respond_to do |format|
      format.json do
        render json: { status: :ok }, status: :ok
      end
    end
  end

  def sort
    ids = params[:form_element_ids].split(',')
    ids.each_with_index do |id, index|
      FormElement.where(id: id, form_id: @form.id).update_all(position: index)
    end

    @form.touch
    render json: @form.form_elements.map(&:position)
  end

  private

  def permitted_params
    params.require(:form_element).permit(:label, :name, :choices, :data_type, :required, :default_value)
  end

  def find_form
    @form = Form.find params[:form_id]
  end
end
