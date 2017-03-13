require 'rails_helper'

describe CallTool::Stats do
  let!(:page) { create(:page, :with_call_tool) }
  subject { CallTool::Stats.new(page) }

  describe 'member_calls:member_calls:status_totals_by_day' do
    let(:data) { subject.to_h[:last_week][:member_calls][:status_totals_by_day] }
    before do
      Timecop.travel(3.days.ago) do
        create_list(:call, 3, :connected, page: page)
        create(:call, :started, page: page)
      end
    end

    it 'returns an array of 7 items' do
      expect(data.count).to eq 7
    end

    it 'returns an empty row if now calls where made on that day' do
      expect(data.first['date']).to eq 6.days.ago.to_date.to_s(:short)
      expect(data.first.keys).to include('unstarted', 'started', 'connected', 'failed')
      expect(
        data.first.slice('unstarted', 'started', 'connected', 'failed').values
      ).to eq [0,0,0,0]
    end

    it 'returns the appropriate calls count when calls are made' do
      expect(data[3]['connected']).to eq 3
      expect(data[3]['started']).to eq 1
      expect(data[3].slice('unstarted', 'failed').values).to eq [0,0]
    end
  end

  describe 'last_week:member_calls:status_totals' do
    let(:data) { subject.to_h[:last_week][:member_calls][:status_totals] }
    before do
      create_list(:call, 2, :connected, page: page)
      create_list(:call, 3, :started, page: page)
    end

    it 'returns the right values' do
      expect(data['failed']).to eql 0
      expect(data['unstarted']).to eql 0
      expect(data['started']).to eql 3
      expect(data['connected']).to eql 2
    end
  end

  describe '#calls_by_day_and_status' do
    before do
      Timecop.travel 1.day.ago do
        create_list(:call, 2, :with_busy_target_status, page: page)
        create_list(:call, 1, :with_completed_target_status, page: page)
      end
      create_list(:call, 1, :with_completed_target_status, page: page)
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
      create_list(:call, 2, :with_completed_target_status, page: page, target: target_a)
      create_list(:call, 1, :with_busy_target_status,      page: page, target: target_a)
      create_list(:call, 1, :with_completed_target_status, page: page, target: target_b)
    end

    it 'returns the right values' do
      stats = subject.calls_by_target
      expect(stats[target_a.id]['completed']).to eql 2
      expect(stats[target_a.id]['busy']).to eql 1
      expect(stats[target_b.id]['completed']).to eql 1
    end
  end
end
