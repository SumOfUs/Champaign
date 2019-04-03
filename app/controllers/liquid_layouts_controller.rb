# frozen_string_literal: true

class LiquidLayoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_liquid_layout, only: %i[show edit update destroy]

  def index
    @liquid_layouts = LiquidLayout.all
  end

  def new
    @liquid_layout = LiquidLayout.new
  end

  def edit
  end

  def create
    @liquid_layout = LiquidLayout.new(liquid_layout_params)

    respond_to do |format|
      if @liquid_layout.save
        format.html { redirect_to edit_liquid_layout_path(@liquid_layout), notice: 'Liquid layout was successfully created.' }
        format.json { render :show, status: :created, location: @liquid_layout }
      else
        format.html { render :new }
        format.json { render json: @liquid_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @liquid_layout.update(liquid_layout_params)
        format.html { redirect_to edit_liquid_layout_path(@liquid_layout), notice: 'Liquid layout was successfully updated.' }
        format.json { render :show, status: :ok, location: @liquid_layout }
      else
        format.html { render :edit }
        format.json { render json: @liquid_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @liquid_layout.destroy
    respond_to do |format|
      format.html { redirect_to liquid_layouts_url, notice: 'Liquid layout was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_liquid_layout
    @liquid_layout = LiquidLayout.find(params[:id])
  end

  def liquid_layout_params
    params
      .require(:liquid_layout)
      .permit(
        :title,
        :content,
        :description,
        :experimental,
        :primary_layout,
        :post_action_layout,
        :default_follow_up_layout_id
      )
  end
end
