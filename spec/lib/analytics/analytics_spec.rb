require 'spec_helper'
require './lib/analytics/analytics'

describe Analytics::Page do

  context 'action on page' do
    subject { Analytics::Page.new('1') }

    it 'updates total number of actions for page' do
      expect_any_instance_of(Redis).to receive('incr').with('pages:1:total_actions')
      subject.increment_actions
    end
  end
end


describe Analytics do
  subject { Analytics::Page.new('1') }

  describe '#total_actions' do
    before do
      subject.increment_actions(new_member: true)
      2.times{ subject.increment_actions(new_member: false) }
    end

    it 'counts total actions' do
      expect( subject.total_actions ).to eq(3)
    end

    it 'counts new member actions' do
      expect( subject.total_actions(new_members: true) ).to eq(1)
    end
  end
end

