FactoryGirl.define do
  factory :share_facebook, :class => 'Share::Facebook' do
    title "MyString"
    description "MyText"
    page
    button_id 1
  end
end

