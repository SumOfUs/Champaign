# frozen_string_literal: true

# == Schema Information
#
# Table name: liquid_layouts
#
#  id                          :integer          not null, primary key
#  title                       :string
#  content                     :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#  experimental                :boolean          default("false"), not null
#  default_follow_up_layout_id :integer
#  primary_layout              :boolean
#  post_action_layout          :boolean
#

FactoryBot.define do
  factory :liquid_layout do
    title { Faker::Company.bs }
    content { "<div class='fun'></div>" }
    description { Faker::Lorem.sentence }
    experimental { false }

    trait :default do
      title { 'default' }
      content { %( {% include 'petition' %} {% include 'thermometer' %} ) }
    end

    trait :scrolling do
      title { 'scrolling' }
      content { %( {% include 'petition' %} {% include 'thermometer' %} {% include 'fundraiser' %} ) }
    end

    trait :petition do
      title { 'petition template' }
      content { %( {% include 'petition' %} ) }
    end

    trait :donation do
      title { 'donation template' }
      content { %( {% include 'donation' %} ) }
    end

    trait :thermometer do
      title { 'thermometer template' }
      content { %( {% include 'thermometer' %} ) }
    end

    trait :no_plugins do
      title { 'layout with no plugins' }
      content { %( whatever ) }
    end

    trait :experimental do
      title { 'Experimental template' }
      experimental { true }
    end

    trait :post_action_share_layout do
      title { 'post action share template' }
      content {
        %(
              <div class="share-buttons">
                {% unless shares['facebook'] == blank %}
                  <div class="share-buttons__button button--facebook {{ shares['facebook'] }}"></div>
                {% endunless %}
                {% unless shares['twitter'] == blank %}
                  <div class="share-buttons__button button--twitter {{ shares['twitter'] }}"></div>
                {% endunless %}
                {% unless shares['email'] == blank %}
                  <div class="share-buttons__simple-email-link {{ shares['email'] }}"></div>
                {% endunless %}
              </div>
              )
      }
    end
  end
end
