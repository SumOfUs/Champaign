class Target
  include ActiveModel::Model

  attr_accessor :fields

  class << self
    attr_accessor :attributes
    attr_accessor :not_filterable_attributes

    def set_attributes(*attrs)
      @attributes = attrs
      attr_accessor(*attrs)
    end

    def set_not_filterable_attributes(*attrs)
      @not_filterable_attributes = attrs
    end

    def inherited(subclass)
      subclass.instance_eval do
        @attributes = []
        @not_filterable_attributes = []
      end
    end
  end

  def initialize(params = {})
    params = params.symbolize_keys
    params[:fields]&.symbolize_keys!
    super(params)
  end

  def to_hash
    Hash[self.class.attributes.collect { |attr| [attr, send(attr)] }].merge(fields: fields)
  end

  def ==(other)
    to_hash == other.to_hash
  end

  def id
    Digest::SHA1.hexdigest(to_hash.to_s)
  end

  def keys
    self.class.attributes.select { |attr| send(attr).present? } + fields_keys
  end

  def get(key)
    if self.class.attributes.include?(key.to_sym)
      send(key)
    else
      fields[key.to_sym]
    end
  end

  private

  def fields_keys
    fields.select { |_k, v| v.present? }.keys
  end
end
