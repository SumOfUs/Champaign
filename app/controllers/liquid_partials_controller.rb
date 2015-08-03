class LiquidPartialsController < ApplicationController
  before_action :set_liquid_partial, only: [:show, :edit, :update, :destroy]

  # GET /liquid_partials
  # GET /liquid_partials.json
  def index
    @liquid_partials = LiquidPartial.all
  end

  # GET /liquid_partials/1
  # GET /liquid_partials/1.json
  def show
  end

  # GET /liquid_partials/new
  def new
    @liquid_partial = LiquidPartial.new
  end

  # GET /liquid_partials/1/edit
  def edit
  end

  # POST /liquid_partials
  # POST /liquid_partials.json
  def create
    @liquid_partial = LiquidPartial.new(liquid_partial_params)

    respond_to do |format|
      if @liquid_partial.save
        format.html { redirect_to [:edit, @liquid_partial], notice: 'Liquid partial was successfully created.' }
        format.json { render :show, status: :created, location: @liquid_partial }
      else
        format.html { render :new }
        format.json { render json: @liquid_partial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /liquid_partials/1
  # PATCH/PUT /liquid_partials/1.json
  def update
    respond_to do |format|
      if @liquid_partial.update(liquid_partial_params)
        format.html { redirect_to edit_liquid_partial_path(@liquid_partial), notice: 'Liquid partial was successfully updated.' }
        format.json { render :show, status: :ok, location: @liquid_partial }
      else
        format.html { render :edit }
        format.json { render json: @liquid_partial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /liquid_partials/1
  # DELETE /liquid_partials/1.json
  def destroy
    @liquid_partial.destroy
    respond_to do |format|
      format.html { redirect_to liquid_partials_url, notice: 'Liquid partial was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_liquid_partial
      @liquid_partial = LiquidPartial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def liquid_partial_params
      params.require(:liquid_partial).permit(:title, :content)
    end
end
