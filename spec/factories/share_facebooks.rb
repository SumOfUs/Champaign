FactoryGirl.define do
  factory :share_facebook, :class => 'Share::Facebook' do
    title "MyString"
    description "MyText"
    page
  end
end

