# frozen_string_literal: true
class LiquidPartialObserver < ActiveRecord::Observer
  def after_save(_record)
    LiquidRenderer::Cache.invalidate
  end

  def after_destroy(_record)
    LiquidRenderer::Cache.invalidate
  end
end
