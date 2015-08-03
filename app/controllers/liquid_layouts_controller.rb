class LiquidLayoutsController < ApplicationController
  before_action :set_liquid_layout, only: [:show, :edit, :update, :destroy]

  # GET /liquid_layouts
  # GET /liquid_layouts.json
  def index
    @liquid_layouts = LiquidLayout.all
  end

  # GET /liquid_layouts/1
  # GET /liquid_layouts/1.json
  def show
  end

  # GET /liquid_layouts/new
  def new
    @liquid_layout = LiquidLayout.new
  end

  # GET /liquid_layouts/1/edit
  def edit
  end

  # POST /liquid_layouts
  # POST /liquid_layouts.json
  def create
    @liquid_layout = LiquidLayout.new(liquid_layout_params)

    respond_to do |format|
      if @liquid_layout.save
        format.html { redirect_to @liquid_layout, notice: 'Liquid layout was successfully created.' }
        format.json { render :show, status: :created, location: @liquid_layout }
      else
        format.html { render :new }
        format.json { render json: @liquid_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /liquid_layouts/1
  # PATCH/PUT /liquid_layouts/1.json
  def update
    respond_to do |format|
      if @liquid_layout.update(liquid_layout_params)
        format.html { redirect_to @liquid_layout, notice: 'Liquid layout was successfully updated.' }
        format.json { render :show, status: :ok, location: @liquid_layout }
      else
        format.html { render :edit }
        format.json { render json: @liquid_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /liquid_layouts/1
  # DELETE /liquid_layouts/1.json
  def destroy
    @liquid_layout.destroy
    respond_to do |format|
      format.html { redirect_to liquid_layouts_url, notice: 'Liquid layout was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_liquid_layout
      @liquid_layout = LiquidLayout.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def liquid_layout_params
      params.require(:liquid_layout).permit(:title, :content)
    end
end
