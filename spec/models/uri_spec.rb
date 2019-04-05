# frozen_string_literal: true

# == Schema Information
#
# Table name: uris
#
#  id         :integer          not null, primary key
#  domain     :string
#  path       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer
#
# Indexes
#
#  index_uris_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

require 'rails_helper'

describe Uri do
  let(:page) { create :page }
  let(:uri) { build :uri, page: page }

  describe 'domain' do
    it "is invalid if it's nil" do
      uri.domain = nil
      expect(uri).to be_invalid
    end

    it "is invalid if it's an empty string" do
      uri.domain = ''
      expect(uri).to be_invalid
    end

    it "is invalid if it doesn't have a period" do
      uri.domain = 'crazytime'
      expect(uri).to be_invalid
    end

    it "is valid if it's a domain name" do
      uri.domain = 'hustle.life'
      expect(uri).to be_valid
    end

    it "is valid if it's a domain name with a subdomain" do
      uri.domain = 'google.abc.xyz'
      expect(uri).to be_valid
    end
  end

  describe 'path' do
    it 'formats nil to /' do
      uri.path = nil
      expect(uri).to be_valid
      expect(uri.path).to eq '/'
    end

    it 'automatically prepends / to an empty string' do
      uri.path = ''
      expect(uri).to be_valid
      expect(uri.path).to eq '/'
    end

    it 'does not prepend / to /' do
      uri.path = '/'
      expect(uri).to be_valid
      expect(uri.path).to eq '/'
    end

    it 'automatically prepends / to abc/def' do
      uri.path = 'abc/def'
      expect(uri).to be_valid
      expect(uri.path).to eq '/abc/def'
    end

    it 'is valid with a long but reasonable path' do
      path = '/maxi/45/pali?key=1&other=fun'
      uri.path = path
      expect(uri).to be_valid
      expect(uri.path).to eq path
    end
  end

  describe 'page' do
    subject { uri }
    it { is_expected.to respond_to :page }
    it { is_expected.to respond_to :page= }
    it { is_expected.to respond_to :page_id }
    it { is_expected.to respond_to :page_id= }

    it 'is invalid without a page' do
      uri.page_id = nil
      expect(uri).to be_invalid
    end

    it 'is invalid with a non-existent page' do
      uri.page_id = 456_789
      expect(uri).to be_invalid
    end
  end
end
