class Image < ActiveRecord::Base

  has_attached_file :content

  validates_attachment_presence :content
  validates_attachment_size :content, less_than: 20.megabytes
  validates_attachment_content_type :content, :content_type => ["image/tiff", "image/jpeg", "image/jpg", "image/png", "image/x-png", "image/gif"]

  belongs_to :widget

end