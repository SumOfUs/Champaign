class TemplatesController < ApplicationController
  def index
    @templates = Template.where active: true
  end

  def show
    @template = Template.find params[:id]
  end

  def new
    @template = Template.new
    @widget_types = WidgetType.where(active: true).all
  end

  def create
    permitted_params = TemplateParameters.new(params).permit
    template = Template.create permitted_params
    template.widget_types = WidgetType.find params[:widget_types]
    template.save
    redirect_to template, notice: 'Template created'
  end

  def edit
    @template = Template.find params[:id]
  end

  def update
    @template = Template.find params[:id]
    permitted_params = TemplateParameters.new(params).permit
    @template.update_attribute permitted_params
    @template.widget_types = params[:widget_types]
    @template.save
  end
end
