FactoryGirl.define do
  factory :call_tool, class: 'Plugins::CallTool' do
    association :page
    targets do
      { US: [{id: 1, name: Faker::Name.name, phone: Faker::PhoneNumber.phone_number}] }
    end
  end
end
