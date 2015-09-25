class PagesTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :page
end
