class Share::Twitter < ActiveRecord::Base
  include Share::Variant

  validates :description, presence: true
  validate :has_link

  def has_link
    errors.add(:description, "does not contain {LINK}") unless description =~ /\{LINK\}/
  end
end
