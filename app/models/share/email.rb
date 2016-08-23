class Share::Email < ActiveRecord::Base
  include Share::Variant

  validates :subject, :body, presence: true
  validate :has_link

  def has_link
    errors.add(:body, "does not contain {LINK}") unless body =~ /\{LINK\}/
  end
end

