class Share::Button < ActiveRecord::Base
  has_many :facebooks, class_name: 'Share::Facebook'
end
