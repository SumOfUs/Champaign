# frozen_string_literal: true
FactoryGirl.define do
  factory :image do
    content { File.new("#{Rails.root}/spec/fixtures/cat.jpg") }
  end
end
