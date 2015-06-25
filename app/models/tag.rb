class Tag < ActiveRecord::Base
  validates_presence_of :tag_name, :actionkit_uri
  validates_uniqueness_of :tag_name, :actionkit_uri
end
