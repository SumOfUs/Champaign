FactoryGirl.define do
  factory :share_email, :class => 'Share::Email' do
    subject "MyString"
    body "MyText {LINK}"
    campaign_page nil
    sp_id ""
    button_id 1
  end

end
