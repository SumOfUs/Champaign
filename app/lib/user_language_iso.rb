# frozen_string_literal: true

class UserLanguageISO
  SUPPORTED = %w[de en es fr].freeze

  def self.for(language)
    new(language).to_h
  end

  def initialize(language)
    @language = language
  end

  def to_h
    supported? ? { key => 1 } : {}
  end

  def key
    "user_#{iso_code}".to_sym
  end

  def iso_code
    @language.code.downcase
  end

  def supported?
    SUPPORTED.include?(@language.code)
  end
end
