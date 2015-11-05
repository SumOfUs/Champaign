require 'rails_helper'

describe ActionUser do
  let(:user_with_akid) {ActionUser.create! actionkit_user_id: 'test' }
  let(:user_without_akid) {ActionUser.create! actionkit_user_id: 'fake_id'}

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
    expect(ActionUser.find_action_user_from_request('test', nil)).to eq(user)
  end

  it 'finds users by id' do
    user = user_without_akid
    expect(ActionUser.find_action_user_from_request(nil, user.id)).to eq(user)
  end

  it 'returns nil when it cannot find any users' do
    _ = user_without_akid
    expect(ActionUser.find_action_user_from_request(nil, nil)).to eq(nil)
  end

end
