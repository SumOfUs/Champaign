class Image < ActiveRecord::Base
  has_paper_trail

  has_attached_file :content,
                    styles: {
                        medium: '300x300>',
                        thumb: '100x100#',
                        medium_square: '700x500#',
                        facebook: '1200x630>',
                        large: '1920x'
                    },
                    convert_options: {
                        all: '-strip -interlace Plane'
                    },
                    default_url: '/images/:style/missing.png'

  validates_attachment_presence :content
  validates_attachment_size :content, less_than: 20.megabytes
  validates_attachment_content_type :content, content_type: %w(image/tiff image/jpeg image/jpg image/png image/x-png image/gif)

  belongs_to :page, touch: true
  has_one    :page_using_as_primary, class_name: 'Page', dependent: :nullify, foreign_key: :primary_image_id
  has_many   :share_facebooks, dependent: :nullify, class_name: 'Share::Facebook'
end
