# frozen_string_literal: true
# == Schema Information
#
# Table name: actionkit_pages
#
#  id                     :integer          not null, primary key
#  actionkit_id           :integer          not null
#  actionkit_page_type_id :integer          not null
#

class ActionkitPage < ApplicationRecord
  belongs_to :page
  has_paper_trail
end
