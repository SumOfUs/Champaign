# frozen_string_literal: true
# == Schema Information
#
# Table name: pages_tags
#
#  id      :integer          not null, primary key
#  page_id :integer
#  tag_id  :integer
#

class PagesTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :page
end
