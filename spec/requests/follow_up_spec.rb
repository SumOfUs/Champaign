# frozen_string_literal: true

require 'rails_helper'

describe 'rendering a post action share page' do
  let(:liquid_layout) { create :liquid_layout }
  let(:post_action_share_layout) { create :liquid_layout, :post_action_share_layout }
  let!(:page) { create :page, follow_up_liquid_layout: post_action_share_layout }
  let!(:facebook_button) { create :share_button, :facebook, page_id: page.id }
  let!(:twitter_button) { create :share_button, :twitter, page_id: page.id }
  let!(:email_button) { create :share_button, :email, page_id: page.id }

  let(:facebook_variant_div) { 'div class="share-buttons__button button--facebook' }
  let(:twitter_variant_div) { 'div class="share-buttons__button button--twitter' }
  let(:email_variant_div) { 'div class="share-buttons__simple-email-link' }

  let(:subject) do
    VCR.use_cassette('money_from_oxr') do
      get "/a/#{page.slug}/follow-up"
      expect(response.successful?).to be true
    end
  end

  describe 'a page with no variants' do
    it 'renders the share container but no buttons for a page with no variants' do
      subject
      expect(response.body).to include('<div class="share-buttons">')
      expect(response.body).to_not include(facebook_variant_div)
      expect(response.body).to_not include(twitter_variant_div)
      expect(response.body).to_not include(email_variant_div)
    end
  end

  describe 'a page with only facebook variant' do
    let!(:facebook_variant) { create :share_facebook, page_id: page.id, button_id: facebook_button.id }
    it 'renders a facebook button' do
      subject
      expect(response.body).to include(facebook_variant_div)
    end
    it 'does not render twitter and e-mail buttons' do
      subject
      expect(response.body).to_not include(twitter_variant_div)
      expect(response.body).to_not include(email_variant_div)
    end
  end

  describe 'a page with facebook, twitter and and email variants' do
    let!(:facebook_variant) { create :share_facebook, page_id: page.id, button_id: facebook_button.id }
    let!(:twitter_variant) { create :share_twitter, page_id: page.id, button_id: twitter_button.id }
    let!(:email_variant) { create :share_email, page_id: page.id, button_id: email_button.id }

    it 'renders all of the buttons' do
      subject
      expect(response.body).to include(facebook_variant_div)
      expect(response.body).to include(twitter_variant_div)
      expect(response.body).to include(email_variant_div)
    end

    it 'renders only the remaining buttons if the facebook button is deleted' do
      facebook_variant.delete
      subject
      expect(response.body).to_not include(facebook_variant_div)
      expect(response.body).to include(twitter_variant_div)
      expect(response.body).to include(email_variant_div)
    end
    it 'renders only the remaining buttons if the twitter and facebook buttons are deleted' do
      facebook_variant.delete
      twitter_variant.delete
      subject
      expect(response.body).to_not include(facebook_variant_div)
      expect(response.body).to_not include(twitter_variant_div)
      expect(response.body).to include(email_variant_div)
    end
    it 'renders no buttons if all the share variants get deleted' do
      facebook_variant.delete
      twitter_variant.delete
      email_variant.delete
      subject
      expect(response.body).to_not include(facebook_variant_div)
      expect(response.body).to_not include(twitter_variant_div)
      expect(response.body).to_not include(email_variant_div)
    end
  end
end
