# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  content_content_type :string
#  content_file_name    :string
#  content_file_size    :bigint(8)
#  content_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  page_id              :integer
#
# Indexes
#
#  index_images_on_page_id  (page_id)
#

FactoryBot.define do
  factory :image do
    content { File.new("#{Rails.root}/spec/fixtures/cat.jpg") }
  end
end
