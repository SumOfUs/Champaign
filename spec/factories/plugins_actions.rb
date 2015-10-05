FactoryGirl.define do
  factory :plugins_action, :class => 'Plugins::Action' do
    page nil
    active false
    form nil
    cta "Sign the Petition"
    target "The man"
    description "Gotta save the world and stuff"
  end
end
