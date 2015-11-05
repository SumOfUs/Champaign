require 'rails_helper'

describe ActionUser do

  let(:ak_user_id) { '7145943'}
  let(:akid) { "14203.#{ak_user_id}.Si3iNOw"}
  let(:fake_akid) { '12345.1234567.RzxR1d' }

  let!(:user_with_akid) { create :action_user, actionkit_user_id: ak_user_id }
  let!(:user_without_akid) { create :action_user, actionkit_user_id: nil }
  let!(:confounding_user) { create :action_user, actionkit_user_id: "7145902"}

  let(:action_user) { create :action_user }
  subject { action_user }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :country }
  it { is_expected.to respond_to :first_name }
  it { is_expected.to respond_to :last_name }
  it { is_expected.to respond_to :city }
  it { is_expected.to respond_to :postal_code }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :address1 }
  it { is_expected.to respond_to :address2 }

  describe 'find_from_request' do
    it 'finds users by akid' do
      expect(ActionUser.find_from_request(akid: akid)).to eq user_with_akid
    end

    it 'finds users by id' do
      expect(ActionUser.find_from_request(id: user_without_akid.id)).to eq user_without_akid
    end

    it 'returns nil when given no params' do
      expect(ActionUser.find_from_request).to eq nil
    end

    it 'returns nil when given params matching nothing' do
      expect(ActionUser.find_from_request(id: '999999999', akid: fake_akid)).to eq nil
    end

    it 'finds by akid when given id matching nothing' do
      expect(ActionUser.find_from_request(id: '999999999', akid: akid)).to eq user_with_akid
    end

    it 'finds by id when given akid matching nothing' do
      expect(ActionUser.find_from_request(id: user_with_akid.id, akid: fake_akid)).to eq user_with_akid
    end

    it 'finds by matching akid when given id and akid matching different records' do
      expect(ActionUser.find_from_request(id: user_without_akid.id, akid: akid)).to eq user_with_akid
    end

    it 'finds first created when duplicate akids in db' do
      other_with_akid = create :action_user, actionkit_user_id: ak_user_id
      expect(ActionUser.find_from_request(akid: akid)).to eq user_with_akid
    end

  end

end
