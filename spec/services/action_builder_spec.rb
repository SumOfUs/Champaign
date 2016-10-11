# frozen_string_literal: true
require 'rails_helper'

describe ActionBuilder do
  let(:page) { create :page }
  let(:member) { create :member }
  let(:found_action) { Action.where(member: member, page: page).first }

  # Create a class which includes the ActionBuilder.
  class MockActionBuilder
    include ActionBuilder

    def initialize(params)
      @params = params
    end
  end

  subject { MockActionBuilder.new(page_id: page.id, email: member.email).build_action }

  context 'with existing member' do
    it 'increments cache counter with new_member as false' do
      expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
      subject
    end
  end

  context 'with new member' do
    it 'increments cache counter with new_member as true' do
      expect(Analytics::Page).to receive(:increment).with(page.id, new_member: true)
      MockActionBuilder.new(page_id: page.id, email: 'new@example.com').build_action
    end
  end

  it 'enqueues action' do
    expect(ChampaignQueue).to receive(:push)
    subject
  end

  it 'correctly finds the expected page' do
    mab = MockActionBuilder.new(page_id: page.id)
    expect(mab.page).to eq(page)
  end

  it 'correctly finds created users' do
    mab = MockActionBuilder.new(email: member.email)
    expect(mab.member).to eq(member)
  end

  it 'correctly changes the attributes of provided users' do
    person = member
    not_real = 'Not a real country.'
    expect(person.country).to_not eq(not_real)
    mab = MockActionBuilder.new(email: person.email, country: not_real)
    expect(mab.member.country).to eq(not_real)
  end

  it 'correctly builds and returns actions' do
    mab = MockActionBuilder.new(page_id: page.id, email: member.email)
    expect(mab.build_action).to eq(found_action)
    expect(found_action).not_to be_blank
  end

  it 'correctly builds and finds previous actions' do
    mab = MockActionBuilder.new(page_id: page.id, email: member.email)
    mab.build_action
    expect(mab.previous_action).to eq(found_action)
    expect(found_action).not_to be_blank
  end

  describe 'previous_action' do
    let!(:page2) { create :page }
    let!(:page3) { create :page }
    let!(:page4) { create :page }
    let(:mab) { MockActionBuilder.new(page_id: page.id, email: member.email) }

    it 'returns nil if no previous action on any page' do
      expect(mab.previous_action).to eq nil
    end

    it 'returns nil if previous action on another page' do
      create :action, page: page2, member: member
      expect(mab.previous_action).to eq nil
    end

    it 'returns nil if previous action on another page in a different campaign' do
      create :campaign, pages: [page2, page3]
      create :action, page: page2, member: member
      expect(mab.previous_action).to eq nil
    end

    it 'returns action on current page if one exists' do
      action = create :action, page: page, member: member
      expect(mab.previous_action).to eq action
    end

    it 'returns action on other page in campaign if one campaign' do
      create :campaign, pages: [page, page2, page3]
      action = create :action, page: page3, member: member
      expect(mab.previous_action).to eq action
    end

    it 'returns action on other page in campaign if multiple campaigns' do
      create :campaign, pages: [page, page2]
      create :campaign, pages: [page3, page4]
      action = create :action, page: page2, member: member
      expect(mab.previous_action).to eq action
    end
  end

  describe 'donor_status' do
    let(:params) { { page_id: page.id, email: member.email } }
    let(:mab) { mab = MockActionBuilder.new(params) }

    describe 'when member is nondonor' do
      it 'it starts as nondonor' do
        expect(member.donor_status).to eq 'nondonor'
      end

      it 'stays nondonor when action is not donation' do
        mab.build_action
        expect(member.reload.donor_status).to eq 'nondonor'
      end

      it 'becomes donor when action is non-recurring donation' do
        mab.build_action(donation: true)
        expect(member.reload.donor_status).to eq 'donor'
      end

      it 'becomes recurring_donor when action is recurring donation' do
        params[:is_subscription] = true
        mab.build_action(donation: true)
        expect(member.reload.donor_status).to eq 'recurring_donor'
      end
    end

    describe 'when member is donor' do
      before :each do
        member.donor!
      end

      it 'starts as donor' do
        expect(member.donor_status).to eq 'donor'
      end

      it 'stays donor when action is not donation' do
        mab.build_action
        expect(member.reload.donor_status).to eq 'donor'
      end

      it 'stays donor when action is non-recurring donation' do
        mab.build_action(donation: true)
        expect(member.reload.donor_status).to eq 'donor'
      end

      it 'becomes recurring_donor when action is recurring donation' do
        params[:is_subscription] = true
        mab.build_action(donation: true)
        expect(member.reload.donor_status).to eq 'recurring_donor'
      end
    end

    describe 'when member is recurring_donor' do
      before :each do
        member.recurring_donor!
      end

      it 'starts as recurring_donor' do
        expect(member.donor_status).to eq 'recurring_donor'
      end

      it 'stays recurring_donor when action is not donation' do
        mab.build_action
        expect(member.reload.donor_status).to eq 'recurring_donor'
      end

      it 'stays recurring_donor when action is non-recurring donation' do
        mab.build_action(donation: true)
        expect(member.reload.donor_status).to eq 'recurring_donor'
      end

      it 'stays recurring_donor when action is recurring donation' do
        params[:is_subscription] = true
        mab.build_action(donation: true)
        expect(member.reload.donor_status).to eq 'recurring_donor'
      end
    end
  end

  describe 'permitted_keys' do
    let(:mab) { MockActionBuilder.new(page_id: page.id, email: member.email) }

    it 'returns symbols' do
      expect(mab.permitted_keys.map(&:class).uniq).to eq [Symbol]
    end

    it 'does not include the id' do
      expect(mab.permitted_keys).not_to include(:id)
    end

    it 'includes all the other keys of member' do
      expect(mab.permitted_keys)
        .to include(
          :email,
          :country,
          :first_name,
          :last_name,
          :city,
          :postal,
          :title,
          :address1,
          :address2,
          :actionkit_user_id
        )
    end
  end

  describe 'action_referrer_email' do
    let(:base_params) { { page_id: page.id, email: member.email } }
    describe 'is not added if referrer_id' do
      it 'is not included' do
        action = MockActionBuilder.new(base_params).build_action
        expect(action.form_data.keys).not_to include('action_referrer_email')
      end

      it 'is blank' do
        action = MockActionBuilder.new(base_params.merge(referrer_id: '')).build_action
        expect(action.form_data.keys).not_to include('action_referrer_email')
      end

      it "is an id of a member that doesn't exist" do
        action = MockActionBuilder.new(base_params.merge(referrer_id: 1_234_567_890)).build_action
        expect(action.form_data.keys).not_to include('action_referrer_email')
      end

      it 'is an id of a member with no email' do
        m2 = create :member, email: ''
        action = MockActionBuilder.new(base_params.merge(referrer_id: m2.id)).build_action
        expect(action.form_data.keys).not_to include('action_referrer_email')
      end
    end

    it 'is added to form_data if it is the id of a member' do
      m2 = create :member, email: 'asdf@hjkl.com'
      action = MockActionBuilder.new(base_params.merge(referrer_id: m2.id)).build_action
      expect(action.form_data['action_referrer_email']).to eq 'asdf@hjkl.com'
    end
  end

  describe 'filtered_params' do
    let(:params) do
      {
        email: 'silly@billy.com',
        country: 'US',
        first_name: 'Silly',
        last_name: 'Billy',
        city: 'Northampton',
        postal: '01060',
        address1: '10 Coates St.',
        address2: ''
      }
    end

    describe 'passes all' do
      it 'keys as symbols' do
        mab = MockActionBuilder.new(params)
        expect(mab.filtered_params).to eq params
      end

      it 'keys as strings' do
        mab = MockActionBuilder.new(params.stringify_keys)
        expect(mab.filtered_params).to eq params
      end

      it 'keys with indifferent access' do
        mab = MockActionBuilder.new(params.with_indifferent_access)
        expect(mab.filtered_params).to eq params
      end

      it 'keys as action parameters' do
        mab = MockActionBuilder.new(ActionController::Parameters.new(params))
        expect(mab.filtered_params).to eq params
      end
    end

    describe 'filters irrelevant' do
      let(:porky_params) { params.merge(page_id: page.id, form_id: '3', blerg: false, akid: '1234.514.lQVxcW') }

      it 'keys as symbols' do
        mab = MockActionBuilder.new(porky_params)
        expect(mab.filtered_params).to eq params
      end

      it 'keys as strings' do
        mab = MockActionBuilder.new(porky_params.stringify_keys)
        expect(mab.filtered_params).to eq params
      end

      it 'keys with indifferent access' do
        mab = MockActionBuilder.new(porky_params.with_indifferent_access)
        expect(mab.filtered_params).to eq params
      end

      it 'keys as action parameters' do
        mab = MockActionBuilder.new(ActionController::Parameters.new(porky_params))
        expect(mab.filtered_params).to eq params
      end

      it 'but passes them through to form_data' do
        mab = MockActionBuilder.new(porky_params)
        expect { mab.build_action }.to change { Action.count }.by 1
        expect(Action.last.form_data).to match a_hash_including(params.stringify_keys)
      end
    end
  end
end
