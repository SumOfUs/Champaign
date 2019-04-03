# frozen_string_literal: true

class LiquidPartialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_liquid_partial, only: %i[show edit update destroy]

  def index
    @liquid_partials = LiquidPartial.all
  end

  def new
    @liquid_partial = LiquidPartial.new
  end

  def edit
  end

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

  def destroy
    @liquid_partial.destroy
    respond_to do |format|
      format.html { redirect_to liquid_partials_url, notice: 'Liquid partial was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_liquid_partial
    @liquid_partial = LiquidPartial.find(params[:id])
  end

  def liquid_partial_params
    params.require(:liquid_partial).permit(:title, :content)
  end
end
