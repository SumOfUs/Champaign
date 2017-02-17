# frozen_string_literal: true
require 'rails_helper'

describe ActionCollator do
  let(:a1) { build :action, form_data: { phone: '12345', name: 'Hocus' } }
  let(:a2) { build :action, form_data: { name: 'Pocus', postal: '90019', action_foo: 'bar' } }

  describe 'keys' do
    it "includes the keys present on any action's form data" do
      expect(ActionCollator.new([a1, a2]).keys).to match_array %w(phone name postal action_foo)
    end

    it "excludes fields that aren't prefixes by action_ or match AK fields" do
      form_data = { form_id: '123', action_foo: 'bar', postal: '12345', commit: 'G', foo: 'bar' }
      a = build :action, form_data: form_data
      expect(ActionCollator.new([a]).keys).to match_array %w(action_foo postal)
    end

    it 'excludes action_referrer_email and action_express_donation' do
      form_data = { action_referrer_email: 'a', action_express_donation: '1',
                    action_referer: 'blah', country: 'NI' }
      a = build :action, form_data: form_data
      expect(ActionCollator.new([a]).keys).to match_array ['country']
    end
  end

  describe 'headers' do
    it 'removes appropriate prefixes and titleizes' do
      form_data = {
        action_textentry_message: 'a',
        action_box_tesla_shareholder: 'a',
        action_dropdown_bank: 'a',
        action_choice_marital_status: 'a',
        action_inspiration: 'a',
        postal: '90019'
      }
      a = build :action, form_data: form_data
      expected = ['Message', 'Tesla Shareholder', 'Bank', 'Marital Status', 'Inspiration', 'Postal']
      expect(ActionCollator.new([a]).headers).to match_array(expected)
    end
  end

  describe 'hashes' do
    it 'turns actions into hashes' do
      expect(ActionCollator.new([a1, a2]).hashes).to match_array([
        { name: 'Pocus', postal: '90019', action_foo: 'bar', phone: nil },
        { name: 'Hocus', postal: nil, action_foo: nil, phone: '12345' }
      ].map(&:stringify_keys))
    end
  end

  describe 'csv' do
    let(:content_rows) { [',Pocus,90019,bar', '12345,Hocus,,'] }

    it 'has the headers as the first line' do
      expect(ActionCollator.csv([a1, a2]).split("\n")[0]).to eq('Phone,Name,Postal,Foo')
    end

    it 'has a line for each action, and a header line' do
      expect(ActionCollator.csv([a1, a2]).split("\n").size).to eq 3
    end

    it 'has all the values for each action' do
      expect(ActionCollator.csv([a1, a2]).split("\n").last(2)).to match_array(content_rows)
    end

    it 'does not have the headers if skip_headers is passed as true' do
      expect(ActionCollator.csv([a1, a2], skip_headers: true).split("\n")).to match_array(content_rows)
    end
  end

  describe 'run' do
    it 'returns hashes, keys, and headers' do
      ac = ActionCollator.new([a1, a2])
      expect(ActionCollator.run([a1, a2])).to eq([ac.hashes, ac.keys, ac.headers])
    end
  end
end
