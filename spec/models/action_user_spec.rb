require 'rails_helper'

RSpec.describe ActionUser, type: :model do
  let(:user_with_akid) {ActionUser.create! actionkit_user_id: 'test' }
  let(:user_without_akid) {ActionUser.create! actionkit_user_id: 'fake_id'}

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
