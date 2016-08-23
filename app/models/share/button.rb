# frozen_string_literal: true
class Share::Button < ActiveRecord::Base
  belongs_to :page
  validates :url, presence: true, allow_blank: false
end
