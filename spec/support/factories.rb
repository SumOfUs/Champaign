FactoryGirl.define do

  sequence :email do |n| "person#{n}@gmail.com" end
  sequence :slug do |n| "petition-#{n}" end
  sequence :page_display_order do |n| n end

  factory :text_widget, aliases: [:widget] do
    content { { body_html: Faker::Lorem.paragraph(2) } }
    page_display_order
    type "TextWidget"
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

end
