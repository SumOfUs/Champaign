# frozen_string_literal: true

class EmailTool::Target
  include ActiveModel::Model

  MAIN_ATTRS = %i[
    name
    title
    email
  ].freeze

  NOT_FILTERABLE = %i[
    email
  ].freeze

  attr_accessor(*MAIN_ATTRS)
  attr_accessor :fields

  validates :email, email: true, presence: true
  validates :name, presence: true

  def to_hash
    Hash[MAIN_ATTRS.collect { |attr| [attr, send(attr)] }].merge(fields: fields)
  end

  def ==(other)
    to_hash == other.to_hash
  end

  def id
    Digest::SHA1.hexdigest(to_hash.to_s)
  end

  def keys
    MAIN_ATTRS.map(&:to_s).select { |attr| send(attr).present? } + fields_keys
  end

  def get(key)
    if MAIN_ATTRS.include?(key.to_sym)
      send(key)
    else
      fields[key]
    end
  end

  private

  def fields_keys
    if fields.present?
      fields.select { |_k, v| v.present? }.keys
    else
      []
    end
  end
end
