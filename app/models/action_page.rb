class ActionPage < ActiveRecord::Base
  attr_accessor :action_page_id, :title, :slug, :active, :featured

  belongs_to :language
  belongs_to :campaign
end