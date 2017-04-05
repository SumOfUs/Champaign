# frozen_string_literal: true
require 'rails_helper'

describe ActionCollator do
  let(:a1) { build :action, form_data: { phone: '12345', name: 'Hocus', id: 1 } }
  let(:a2) { build :action, form_data: { name: 'Pocus', postal: '90019', action_foo: 'bar', id: 2 } }

  describe 'keys' do
    it "includes the keys present on any action's form data" do
      expect(ActionCollator.new([a1, a2]).keys).to match_array %i(phone name postal action_foo id publish_status)
    end

    it "excludes fields that aren't prefixes by action_ or match AK fields" do
      form_data = { form_id: '123', action_foo: 'bar', postal: '12345', commit: 'G', foo: 'bar' }
      a = build :action, form_data: form_data
      expect(ActionCollator.new([a]).keys).to match_array %i(action_foo postal id publish_status)
    end

    it 'excludes action_referrer_email and action_express_donation' do
      form_data = { action_referrer_email: 'a', action_express_donation: '1',
                    action_referer: 'blah', country: 'NI' }
      a = build :action, form_data: form_data
      expect(ActionCollator.new([a]).keys).to match_array %i(country id publish_status)
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
      expected = {
        id: 'Id',
        publish_status: 'Publish Status',
        action_textentry_message: 'Message',
        action_box_tesla_shareholder: 'Tesla Shareholder',
        action_dropdown_bank: 'Bank',
        action_choice_marital_status: 'Marital Status',
        action_inspiration: 'Inspiration',
        postal: 'Postal'
      }
      expect(ActionCollator.new([a]).headers).to eq(expected)
    end
  end

  describe 'hashes' do
    it 'turns actions into hashes' do
      expect(ActionCollator.new([a1, a2]).hashes).to match_array([
        { name: 'Pocus', postal: '90019', action_foo: 'bar', phone: nil, id: 2, publish_status: 'default' },
        { name: 'Hocus', postal: nil, action_foo: nil, phone: '12345', id: 1, publish_status: 'default' }
      ])
    end
  end

  describe 'csv' do
    let(:content_rows) { [',Pocus,90019,bar,default,2', '12345,Hocus,,,default,1'] }

    it 'has the headers as the first line' do
      expect(ActionCollator.csv([a1, a2]).split("\n")[0]).to eq('Phone,Name,Postal,Foo,Publish Status,Id')
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

    it 'puts quotes around fields with commas' do
      a = build :action, form_data: { phone: '12345', name: 'a,b,c', id: 1 }
      expect(ActionCollator.csv([a]).split("\n").last).to eq('12345,"a,b,c",default,1')
    end
  end

  describe 'run' do
    it 'returns hashes and headers' do
      ac = ActionCollator.new([a1, a2])
      expect(ActionCollator.run([a1, a2])).to eq([ac.hashes, ac.headers])
    end
  end
end
