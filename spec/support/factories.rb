FactoryGirl.define do

  sequence :email do |n| "person#{n}@gmail.com" end
  sequence :slug do |n| "petition-#{n}" end
  sequence :page_display_order do |n| n end
  sequence :actionkit_id do |n| n end
  sequence :actionkit_uri do |n| "/rest/v1/tag/#{n}/" end
  sequence :tag_name do |n| "#{['+','@','*'].sample}#{Faker::Commerce.color}#{n}" end

  factory :text_body_widget, aliases: [:widget] do
    content { { text_body_html: Faker::Lorem.paragraph(2) } }
    page_display_order
    type "TextBodyWidget"
  end

  factory :petition_widget do
    content {
      {
        petition_text: Faker::Lorem.paragraph(2),
        require_full_name: true,
        require_email_address: true,
        require_state: false,
        require_country: true,
        require_postal_code: false,
        require_address: false,
        require_city: false,
        require_phone: false,
        checkboxes: [],
        select_box: {},
        form_button_text: "Stop 'em!"
      }
    }
    page_display_order
    type "PetitionWidget"
  end

  factory :thermometer_widget do
    content {
      {
        goal: 10000,
        count: 100,
        autoincrement: true
      }
    }
    page_display_order
    type "ThermometerWidget"
  end

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

  factory :language do
    language_code 'en'
    language_name 'English'
  end

  factory :campaign_page, aliases: [:page] do
    title { Faker::Company.bs }
    slug
    active true
    featured false
  end

  factory :campaign do
    campaign_name { Faker::Company.bs }
    active true
  end

  factory :tag do
    tag_name
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
        state: Faker::Address.state,
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
