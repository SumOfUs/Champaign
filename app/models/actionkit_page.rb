# frozen_string_literal: true
class ActionkitPage < ActiveRecord::Base
  belongs_to :page
  has_paper_trail
end
