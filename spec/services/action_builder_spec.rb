require 'rails_helper'

describe ActionBuilder do
  let(:page) { create :page }
  let(:member) { create :member }
  let(:found_action) { Action.where(member: member, page: page).first }
  let(:test_params) { {test: 'yes', foo: 'bar'}}

  # Create a class which includes the ActionBuilder.
  class MockActionBuilder
    include ActionBuilder

    def initialize(params)
      @params = params
    end
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
  end

  it 'correctly builds and finds previous actions' do
    mab = MockActionBuilder.new(page_id: page.id, email: member.email)
    mab.build_action
    expect(mab.previous_action).to eq(found_action)
  end
end
