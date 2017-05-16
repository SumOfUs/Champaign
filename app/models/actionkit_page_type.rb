# frozen_string_literal: true
# == Schema Information
#
# Table name: actionkit_page_types
#
#  id                  :integer          not null, primary key
#  actionkit_page_type :string           not null
#

class ActionkitPageType < ApplicationRecord
  has_many :actionkit_page

  validates :actionkit_page_type, presence: true, uniqueness: true
end
