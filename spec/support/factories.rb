FactoryGirl.define do

  sequence(:email) { |n| "person#{n}@gmail.com" }
  sequence(:slug)  { |n| "petition-#{n}" }
  sequence(:page_display_order) { |n| n }
  sequence(:actionkit_id) { |n| n }
  sequence(:actionkit_uri) { |n| "/rest/v1/tag/#{n}/" }

  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    admin false
  end

  factory :admin, class: :user do
    email
    password { Faker::Internet.password }
    admin true
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
    signature do
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
    end
    initialize_with { attributes }
  end

end
