# frozen_string_literal: true

class EmailTool::Target
  include ActiveModel::Model

  MAIN_ATTRS = %i[
    name
    title
    email
  ].freeze

  FILTERABLE = %i[
    name
    title
  ].freeze

  attr_accessor(*MAIN_ATTRS)
  attr_accessor :fields

  validates :email, email: true
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
    MAIN_ATTRS.map(&:to_s).concat(fields&.keys || [])
  end
end
