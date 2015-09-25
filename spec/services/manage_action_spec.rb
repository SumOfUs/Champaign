require 'rails_helper'

describe ManageAction do
  let(:page) { create(:page) }
  let(:data) { { email: 'bob@example.com', page_id: page.id } }

  describe '#create' do
    subject { ManageAction.new(data).create }

    it 'creates an action' do
      expect(subject).to be_a Action
    end

    it 'creates an action user' do
      expect(subject.action_user.email).to eq('bob@example.com')
    end

    it 'uses existing user if present' do
      create(:action_user, email: 'bob@example.com')

      expect{ subject }.to_not change{ ActionUser.count }.from(1)
    end

    it 'returns existing action if present' do
       action = ManageAction.new(data).create

       expect(subject.id).to eq(action.id)
    end
  end
end
