# frozen_string_literal: true
# == Schema Information
#
# Table name: pages_tags
#
#  id      :integer          not null, primary key
#  page_id :integer
#  tag_id  :integer
#

class PagesTag < ApplicationRecord
  belongs_to :tag,  optional: true
  belongs_to :page,  optional: true
end
