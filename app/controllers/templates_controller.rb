class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_template, only: [:show, :edit, :update, :show_form, :destroy]

  def index
    @templates = Template.where active: true
  end

  def show
  end

  def new
    @template = Template.new
  end

  def create
    # To Omar: This action is correctly making the Template, but not the nested widgets.
    #          I'll sort out the rest of the strong params and finish
    #          the form tomorrow, but you can feel free to use your Creator style here and
    #          in the update action. This controller needs a spec too.
    # 
    #    example params: {"template"=>{"template_name"=>"Hey", "active"=>"1", "thermometer_widget"=>{"page_display_order"=>"2"}, "text_body_widget"=>{"page_display_order"=>"1", "content"=>{"text_body_html"=>"hey hey"}}}, "widget_type"=>"text_body_widget", "utf8"=>"✓", "authenticity_token"=>"ekzDa3XuwKpsVnP4kLlVKFSod+NLJW0fhtUPuvs5FyuxsUGCiI+2gDnUI0rYmpZsbjvTZEDRVWeZPzstJyKAFg==", "commit"=>"Save Template"}
    permitted_params = TemplateParameters.new(params).permit
    @template = Template.new permitted_params
    if @template.save
      redirect_to @template, notice: 'Template created'
    else
      render :new
    end
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
    # user changes which template they want to use as the base for their campaign page.
    render 'templates/show_form', layout: false
  end

  private
  def get_template
    @template = Template.find params[:id]
  end
end
