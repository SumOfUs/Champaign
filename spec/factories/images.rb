FactoryGirl.define do
  factory :image do
    content { File.new("#{Rails.root}/spec/fixtures/cat.jpg") }
  end
end
