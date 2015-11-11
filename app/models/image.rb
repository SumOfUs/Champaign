class Image < ActiveRecord::Base

  has_attached_file :content,
    :styles => {
        :medium=> "300x300>",
        :thumb=> "100x100#",
        :medium_square=> "700x500#",
        :facebook=> "1200x630>",
        :large=> "1920x"
    },
    :convert_options=> {
        :all=> '-strip -interlace Plane'
    },
    :default_url=> "/images/:style/missing.png",
    :path=> ":attachment/:id/:style.:extension",
    :url => ":s3_alias_url",
        :s3_host_alias => ENV["CLOUDFRONT_URL"],
    :s3_credentials => {
        :bucket => ENV["FOG_DIRECTORY"],
        :access_key_id=> ENV["AWS_ACCESS_KEY_ID"],
        :secret_access_key=> ENV["AWS_SECRET_ACCESS_KEY"]
    },
    :default_url=> "/images/:style/missing.png"

  validates_attachment_presence :content
  validates_attachment_size :content, less_than: 20.megabytes
  validates_attachment_content_type :content, :content_type => ["image/tiff", "image/jpeg", "image/jpg", "image/png", "image/x-png", "image/gif"]

  belongs_to :page
  has_one :page_using_as_primary, class_name: 'Page', dependent: :nullify, foreign_key: :primary_image_id
  has_many :share_facebooks, dependent: :nullify, class_name: 'Share::Facebook'
end
