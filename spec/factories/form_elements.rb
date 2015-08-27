FactoryGirl.define do
  factory :form_element do
    form
    label     { Faker::Lorem.word }
    required  false
    data_type 'text'
    visible   true
  end
end
