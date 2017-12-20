class LiquidRenderer
  class Cache
    INVALIDATOR_KEY = 'cache_invalidator'.freeze

    def self.invalidate
      Rails.cache.increment(INVALIDATOR_KEY)
    end

    def initialize(page_key, layout_key)
      @page_key   = page_key
      @layout_key = layout_key
    end

    def fetch(&block)
      Rails.cache.fetch(key_for_markup, &block)
    end

    private

    def key_for_markup
      "liquid_markup:#{invalidator_seed}:#{@page_key}:#{@layout_key}"
    end

    def invalidator_seed
      Rails.cache.fetch(INVALIDATOR_KEY) { 0 }
    end
  end
end
