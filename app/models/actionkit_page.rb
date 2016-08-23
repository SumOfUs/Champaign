class ActionkitPage < ActiveRecord::Base
  belongs_to :page
  has_paper_trail
end
