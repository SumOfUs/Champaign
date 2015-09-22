FactoryGirl.define do
  factory :plugins_action, :class => 'Plugins::Action' do
    campaign_page nil
    active false
    form nil
  end
end
