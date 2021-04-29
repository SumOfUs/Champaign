# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  content_content_type :string
#  content_file_name    :string
#  content_file_size    :bigint(8)
#  content_updated_at   :datetime
#  dimensions           :string
#  created_at           :datetime
#  updated_at           :datetime
#  page_id              :integer
#
# Indexes
#
#  index_images_on_page_id  (page_id)
#

class Image < ApplicationRecord
  # At what point should the image format be converted to jpg
  TO_JPG_SIZE_THRESHOLD = 150_000

  has_paper_trail

  has_attached_file :content,
                    styles: lambda { |attachment|
                      {
                        medium: '300x300>',
                        thumb: '100x100#',
                        medium_square: ['700x500#', attachment.instance.decide_format],
                        facebook: ['1200x630>', attachment.instance.decide_format],
                        large: ['1920x', attachment.instance.decide_format]
                      }
                    },
                    convert_options: {
                      all: '-strip -interlace Plane',
                      large: '-quality 80'
                    },
                    default_url: '/images/:style/missing.png'

  validates_attachment_presence :content
  validates_attachment_size :content, less_than: 20.megabytes
  validates_attachment_content_type :content, content_type: %w[image/tiff image/jpeg image/jpg image/png image/x-png image/gif]

  after_post_process :save_image_dimensions

  belongs_to :page, touch: true
  has_one    :page_using_as_primary, class_name: 'Page', dependent: :nullify, foreign_key: :primary_image_id
  has_many   :share_facebooks, dependent: :nullify, class_name: 'Share::Facebook'

  def decide_format
    content.size.to_i > TO_JPG_SIZE_THRESHOLD ? :jpg : content.content_type.split('/').last
  end

  private

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(content.queued_for_write[:original])
    self.dimensions = "#{geo.width.to_i}:#{geo.height.to_i}"
  end
end
