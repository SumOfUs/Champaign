require 'rails_helper'

describe CallTool::Stats do
  let!(:page) { create(:page, :with_call_tool) }
  subject { CallTool::Stats.for(page) }

  describe '#calls_by_status' do
    before do
      create_list(:call, 2, :with_busy_status, page: page)
      create_list(:call, 3, :with_completed_status, page: page)
    end

    it 'returns the right values' do
      expect(subject.calls_by_status['busy']).to eql 2
      expect(subject.calls_by_status['completed']).to eql 3
    end
  end

  describe '#calls_by_day_and_status' do
    before do
      Timecop.travel 1.day.ago do
        create_list(:call, 2, :with_busy_status, page: page)
        create_list(:call, 1, :with_completed_status, page: page)
      end
      create_list(:call, 1, :with_completed_status, page: page)
    end

    it 'returns the right values' do
      one_day_ago = 1.day.ago.to_date.to_s
      today = Date.today.to_s

      stats = subject.calls_by_day_and_status
      expect(stats[one_day_ago]['busy']).to eql 2
      expect(stats[one_day_ago]['completed']).to eql 1
      expect(stats[today]['completed']).to eql 1
    end
  end

  describe '#calls_by_target' do
    let(:call_tool) { Plugins::CallTool.find_by(page: page) }
    let(:target_a) { call_tool.targets.first }
    let(:target_b) { call_tool.targets[1] }

    before do
      create_list(:call, 2, :with_completed_status, page: page, target: target_a)
      create_list(:call, 1, :with_busy_status,      page: page, target: target_a)
      create_list(:call, 1, :with_completed_status, page: page, target: target_b)
    end

    it 'returns the right values' do
      stats = subject.calls_by_target
      expect(stats[target_a.id]['completed']).to eql 2
      expect(stats[target_a.id]['busy']).to eql 1
      expect(stats[target_b.id]['completed']).to eql 1
    end
  end
end
