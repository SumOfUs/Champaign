# frozen_string_literal: true

require 'rails_helper'

describe Member do
  let(:ak_user_id) { '5678' }
  let(:akid) { ".#{ak_user_id}.hIdbLl" }
  let(:fake_akid) { '12345.1234567.RzxR1d' }

  let!(:user_with_akid) { create :member, actionkit_user_id: ak_user_id }
  let!(:user_without_akid) { create :member, actionkit_user_id: nil }
  let!(:confounding_user) { create :member, actionkit_user_id: '7145902' }

  let(:member) { create :member }
  subject { member }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :country }
  it { is_expected.to respond_to :first_name }
  it { is_expected.to respond_to :last_name }
  it { is_expected.to respond_to :city }
  it { is_expected.to respond_to :postal }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :address1 }
  it { is_expected.to respond_to :address2 }

  it { is_expected.to_not respond_to :postal_code }

  describe 'find_from_request' do
    it 'finds users by akid' do
      expect(Member.find_from_request(akid: akid)).to eq user_with_akid
    end

    it 'finds users by id' do
      expect(Member.find_from_request(id: user_without_akid.id)).to eq user_without_akid
    end

    it 'returns nil when given no params' do
      expect(Member.find_from_request).to eq nil
    end

    it 'returns nil when given params matching nothing' do
      expect(Member.find_from_request(id: '999999999', akid: fake_akid)).to eq nil
    end

    it 'finds by akid when given id matching nothing' do
      expect(Member.find_from_request(id: '999999999', akid: akid)).to eq user_with_akid
    end

    it 'finds by id when given akid matching nothing' do
      expect(Member.find_from_request(id: user_with_akid.id, akid: fake_akid)).to eq user_with_akid
    end

    it 'finds by matching akid when given id and akid matching different records' do
      expect(Member.find_from_request(id: user_without_akid.id, akid: akid)).to eq user_with_akid
    end

    it 'finds first created when duplicate akids in db' do
      other_with_akid = create :member, actionkit_user_id: ak_user_id

      actionkit_user_id = AkidParser.parse(akid, Settings.action_kit.akid_secret)[:actionkit_user_id]
      rec = Member.where(actionkit_user_id: actionkit_user_id).order('created_at ASC').first

      expect(Member.find_from_request(akid: akid).id).to eq rec.id
    end
  end
end
