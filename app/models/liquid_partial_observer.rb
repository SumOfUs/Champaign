class LiquidPartialObserver < ActiveRecord::Observer
  def after_save(_record)
    LiquidRenderer::Cache.invalidate
  end

  def after_destroy(_record)
    LiquidRenderer::Cache.invalidate
  end
end

