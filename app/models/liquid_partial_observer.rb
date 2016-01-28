class LiquidPartialObserver < ActiveRecord::Observer
  def after_save(record)
    LiquidRenderer::Cache.invalidate
  end

  def after_destroy(record)
    LiquidRenderer::Cache.invalidate
  end
end

