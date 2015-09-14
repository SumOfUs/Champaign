class Share::Button < ActiveRecord::Base
  has_many :facebooks, class_name: 'Share::Facebook'
  belongs_to :campaign_page

end

