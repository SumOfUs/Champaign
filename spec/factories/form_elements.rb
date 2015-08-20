FactoryGirl.define do
  factory :form_element do
    label     "Name"
    name      "name"
    required  false
    data_type 'text'
    form nil
    visible true
  end
end
