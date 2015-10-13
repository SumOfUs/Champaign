FactoryGirl.define do

  sequence :email do |n| "person#{n}@gmail.com" end
  sequence :slug do |n| "petition-#{n}" end
  sequence :page_display_order do |n| n end
  sequence :actionkit_id do |n| n end
  sequence :actionkit_uri do |n| "/rest/v1/tag/#{n}/" end

  factory :user do
    email
    password { Faker::Internet.password }
    admin false
  end

  factory :admin, class: :user do
    email
    password { Faker::Internet.password }
    admin true
  end

  factory :campaign do
    name { Faker::Company.bs }
    active true
  end

  factory :tag do
    sequence(:name) { |n| "#{['+','@','*'].sample}#{Faker::Commerce.color}#{n}" }
    actionkit_uri
  end

  factory :actionkit_page_type do
    actionkit_page_type { Faker::Commerce.color }
  end

  factory :actionkit_page do
    actionkit_id
    actionkit_page_type
  end

  factory :template do
    template_name { Faker::Commerce.color }
  end

  factory :petition_signature_params, class: Hash do
    signature {
      {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        country: Faker::Address.country,
        postal: Faker::Address.postcode,
        address: Faker::Address.street_address,
        state: Faker::Address.state,
        city: Faker::Address.city,
        phone: Faker::PhoneNumber.phone_number,
        zip: Faker::Address.zip,
        region: Faker::Config.locale,
        lang: 'En'
      }
    }
    initialize_with { attributes }
  end

end
