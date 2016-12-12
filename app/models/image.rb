# frozen_string_literal: true
# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  content_file_name    :string
#  content_content_type :string
#  content_file_size    :integer
#  content_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  page_id              :integer
#

class Image < ActiveRecord::Base
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
  validates_attachment_content_type :content, content_type: %w(image/tiff image/jpeg image/jpg image/png image/x-png image/gif)

  belongs_to :page, touch: true
  has_one    :page_using_as_primary, class_name: 'Page', dependent: :nullify, foreign_key: :primary_image_id
  has_many   :share_facebooks, dependent: :nullify, class_name: 'Share::Facebook'

  def decide_format
    content.size.to_i > TO_JPG_SIZE_THRESHOLD ? :jpg : content.content_type
  end
end
