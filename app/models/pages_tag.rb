# frozen_string_literal: true
class PagesTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :page
end
