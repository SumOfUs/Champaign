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

  factory :campaign_page, aliases: [:page, :widgetless_page] do
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

end
