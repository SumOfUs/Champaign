FactoryGirl.define do
  factory :plugins_thermometer, :class => 'Plugins::Thermometer' do
    title "MyString"
    offset 1
    goal 1
    page nil
    active false
  end
end
