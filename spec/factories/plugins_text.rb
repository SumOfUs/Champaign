# frozen_string_literal: true
FactoryBot.define do
  factory :plugins_text, class: 'Plugins::Text' do
    content { Faker::Hipster.paragraphs(3).map { |s| "<p>#{s}</p>" }.join("\n") }
    page nil
    active true
    ref nil
  end
end
