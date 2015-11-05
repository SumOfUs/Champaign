require 'rails_helper'

describe ActionUser do

  let(:ak_user_id) { '7145943'}
  let(:akid) { "14203.#{ak_user_id}.Si3iNOw"}
  let(:user_with_akid) { create :action_user, actionkit_user_id: ak_user_id }
  let(:user_without_akid) { create :action_user, actionkit_user_id: nil }

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

  it 'finds users by akid' do
    user = user_with_akid
    expect(ActionUser.find_from_request(akid: akid)).to eq(user)
  end

  it 'finds users by id' do
    user = user_without_akid
    expect(ActionUser.find_from_request(id: user.id)).to eq(user)
  end

  it 'returns nil when it cannot find any users' do
    _ = user_without_akid
    expect(ActionUser.find_from_request).to eq(nil)
  end

end
