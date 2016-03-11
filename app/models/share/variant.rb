module Share::Variant
  extend ActiveSupport::Concern

  included do
    belongs_to :button
    belongs_to :page, touch: true
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
