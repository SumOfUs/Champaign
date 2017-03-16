# frozen_string_literal: true
module Share::Variant
  extend ActiveSupport::Concern

  included do
    after_initialize :set_url

    belongs_to :button
    belongs_to :page, touch: true

    attr_accessor :url

    def url
      button&.url
    end

    def url=(value)
      attribute_will_change!(:url) if url != value
      @url = value
    end

    def url_changed?
      changed.include?(:url)
    end

    def set_url
      self.url = button&.url
    end
  end

  def add_errors(errors_to_add)
    errors_to_add.each do |error|
      errors.add(:base, error)
    end
  end

  def name
    self.class.name.demodulize.underscore
  end

  def self.all
    [Share::Facebook, Share::Twitter, Share::Email].inject([]) do |variations, share_class|
      variations += share_class.all
    end
  end
end
