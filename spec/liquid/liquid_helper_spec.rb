require 'rails_helper'

describe LiquidHelper do

  describe 'member' do

    it 'returns nil if no member given' do
      expect(LiquidHelper.globals[:member]).to eq nil
    end

    it 'includes all of the attributes of a given action user' do
      au = create :action_user
      expect(LiquidHelper.globals(member: au)[:member].keys).to include(*au.attributes.keys.map(&:to_sym))
    end

    it 'gives email as welcome name if no name' do
      au = create :action_user, first_name: nil, last_name: "", email: 'sup@dude.com'
      expect(LiquidHelper.globals(member: au)[:member][:welcome_name]).to eq au.email
    end

    it 'gives first name and last name if available' do
      au = create :action_user, first_name: 'big', last_name: "dog", email: 'sup@dude.com'
      expect(LiquidHelper.globals(member: au)[:member][:welcome_name]).to eq 'big dog'
    end
  end

  describe 'country_option_tags' do

    it 'gives a long html by default' do
      country_option_tags = LiquidHelper.globals[:country_option_tags]
      expect(country_option_tags.length).to be > 5000
      expect(country_option_tags.scan('<option').size).to be > 100
    end

    it 'does not include select tags' do
      expect(LiquidHelper.globals[:country_option_tags]).not_to include('<select')
    end

    it 'does not select a country by default' do
      expect(LiquidHelper.globals[:country_option_tags]).not_to include('selected')
    end

    it 'selects a country if passed request_country as a code' do
      expect(LiquidHelper.globals(request_country: 'AF')[:country_option_tags]).to include('selected')
    end

    it 'does not select a country if passed request_country as a country name' do
      expect(LiquidHelper.globals(request_country: 'Afghanistan')[:country_option_tags]).not_to include('selected')
    end

    it 'selects a country if passed member has a country code' do
      au = create :action_user, country: 'AF'
      expect(LiquidHelper.globals(member: au)[:country_option_tags]).to include('selected')
    end
  end

end
