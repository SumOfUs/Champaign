class LiquidPartial < ActiveRecord::Base
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
end
