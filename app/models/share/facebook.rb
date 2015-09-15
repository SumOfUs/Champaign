class Share::Facebook < ActiveRecord::Base
  belongs_to :button
  belongs_to :campaign_page

  validates :description, :title, presence: true

  has_attached_file :image, styles: { thumb: "300x157>", facebook: "1200x630>", square: "300x300#" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

end

