class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_template, only: [:show, :edit, :update, :show_form, :destroy]

  def get_template
    @template = Template.find params[:id]
  end

  def index
    @templates = Template.where active: true
  end

  def show
  end

  def new
    @template = Template.new
    @widget_types = WidgetType.where(active: true).all
  end

  def create
    permitted_params = TemplateParameters.new(params).permit
    template = Template.new permitted_params
    template.widget_types = WidgetType.find params[:widget_types]
    template.save
    redirect_to template, notice: 'Template created'
  end

  def edit
  end

  def update
    permitted_params = TemplateParameters.new(params).permit
    @template.update_attribute permitted_params
    @template.widget_types = params[:widget_types]
    @template.save
  end

  def show_form
    # This returns the html from templates/show_form.slim without a layout.
    # The HTML gets requested by an AJAX call in campaign page creation, whenever the
    # user changes, which template they want to use as the base for their campaign page.
    render 'templates/show_form', layout: false
  end
end
