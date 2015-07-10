class ImageWidget < Widget
  validates :content, absence: true # for now, the image widget just is a reference to an image

  has_one :image, dependent: :destroy, foreign_key: :widget_id
  accepts_nested_attributes_for :image
end
