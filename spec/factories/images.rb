# frozen_string_literal: true
# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  content_file_name    :string
#  content_content_type :string
#  content_file_size    :integer
#  content_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  page_id              :integer
#

FactoryBot.define do
  factory :image do
    content { File.new("#{Rails.root}/spec/fixtures/cat.jpg") }
  end
end
