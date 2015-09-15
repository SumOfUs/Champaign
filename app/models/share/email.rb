class Share::Email < ActiveRecord::Base
  belongs_to :campaign_page
  belongs_to :button

  validates :subject, :body, presence: true
  validate :has_link

  def has_link
    errors.add(:body, "does not contain {LINK}") unless body =~ /\{LINK\}/
  end

end

