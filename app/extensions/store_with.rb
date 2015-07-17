class StoreWith
  attr_reader :attrs

  class << self
    def model
      Module.new do
        def self.included(base)
          base.extend ClassMethods
        end
      end
    end
  end

  module ClassMethods
    def store_with(attr, &block)
      detail = StoreWith.new(self, attr, &block)
      self.store_accessor attr, detail.attrs
    end
  end

  def initialize(model, location, &block)
    @model = model
    @@location = location
    @attrs = []
    @raw = {}

    instance_eval(&block)
    set_casts
    override
  end

  def override
    @model.class_eval do
      define_method "#{@@location}=" do |attrs|
        assign_attributes(attrs)
        super(attrs) unless attrs.any?
      end
    end
  end

  def set_casts
    @raw.each do |property, type|
      conversion_method = type_converter(type)

      @model.class_eval do
        define_method "#{property}=" do |attr|
          return super(attr) if attr.nil?

          if conversion_method.is_a? Proc
            super(
              conversion_method.call( attr )
            )
          else
            super(attr.send( conversion_method ) )
          end
        end

        define_method property do
          return super() if super().nil?

          if conversion_method.is_a? Proc
            conversion_method.call( super() )
          else
            super().send( conversion_method )
          end
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
    when :float
      :to_f
    when :array
      :to_a
    when :dictionary
      :to_h
    when :boolean
       lambda { |attr| ActiveRecord::Type::Boolean.new.type_cast_from_user(attr) }
    end
  end

  def method_missing(m, *args, &block)
    @attrs << m
    @raw[m] = args.first
  end
end
