class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_template, only: [:show, :edit, :update, :show_form, :destroy]
  before_action :clean_params, only: [:update, :create]

  def index
    @templates = Template.where active: true
  end

  def show
  end

  def new
    @template = Template.new
  end

  def create
    @template = Template.new @template_params
    if @template.save
      redirect_to @template, notice: 'Template created!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @template.update_attributes @template_params
    if @template.save
      redirect_to @template, notice: 'Template updated!'
    else
      render :edit
    end
  end

  def show_form
    # This returns the html from templates/show_form.slim without a layout.
    # The HTML gets requested by an AJAX call in campaign page creation, whenever the
    # user changes which template they want to use as the base for their campaign page.
    render 'templates/show_form', layout: false
  end

  private
  def get_template
    @template = Template.find params[:id]
  end

  def clean_params
    @template_params = TemplateParameters.new(params).permit
  end
end
