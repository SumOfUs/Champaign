class Action < ActiveRecord::Base
  belongs_to :page, counter_cache: :action_count
  belongs_to :member

  has_paper_trail on: [:update, :destroy]
end

