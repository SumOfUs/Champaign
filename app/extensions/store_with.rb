class StoreWith
  attr_reader :attrs

  class << self
    def model
      Module.new do
        def store_with(attr, &block)
          detail = StoreWith.new(self, &block)
          self.store_accessor attr, detail.attrs
        end
      end
    end
  end

  def initialize(model, &block)
    @model = model
    @attrs = []
    @raw = {}

    instance_eval(&block)
    set_casts
  end

  def set_casts
    @raw.each do |property, type|
      conversion_method = type_converter(type)

      @model.class_eval do
        define_method property do
          super().send( conversion_method )
        end
      end
    end
  end

  def type_converter(type)
    case type
    when :string
      :to_s
    when :integer
      :to_i
    end
  end

  def method_missing(m, *args, &block)
    @attrs << m
    @raw[m] = args.first
  end
end

