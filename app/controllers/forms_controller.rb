class FormsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create]
  before_action :find_form, only: [:show, :edit]

  def index
  end

  def show
  end

  def edit
  end

  def create
    @form = Form.create(name: params[:form][:name], master: true)
    redirect_to [:edit, @form]
  end

  def new
    @form = Form.new
  end

  private

  def find_form
    @form = Form.find params[:id]
  end

end
