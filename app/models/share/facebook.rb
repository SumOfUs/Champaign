class Share::Facebook < ActiveRecord::Base
  include Share::Variant

  validates :description, :title, presence: true

  has_attached_file :image, styles: {
    thumb: "300x157>",
    facebook: "1200x630>",
    square: "300x300#" }

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  before_create :attach_default_image

  private

  def attach_default_image
    return if image.exists?

    if page.images.any?
      self.image = page.images.first.content
    end
  end
end

