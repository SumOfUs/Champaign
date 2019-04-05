# frozen_string_literal: true

# TODO: Needs a controller spec
class FormsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_form, only: %i[show edit]

  def index
  end

  def show
  end

  def edit
    @form_element = FormElement.new
  end

  def create
    @form = Form.new(name: params[:form][:name], master: true)

    if @form.save
      redirect_to [:edit, @form]
    else
      render :new
    end
  end

  def new
    @form = Form.new
  end

  private

  def find_form
    @form = Form.find params[:id]
  end
end
