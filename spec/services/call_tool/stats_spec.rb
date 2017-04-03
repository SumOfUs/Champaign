require 'rails_helper'

describe CallTool::Stats do
  let!(:page) { create(:page) }
  let!(:call_tool) { create(:call_tool, page: page, targets: targets )}
  let(:targets) { build_list(:call_tool_target, 3, :with_country) }
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

  describe 'last_week:target_calls' do
    let(:target_a) { targets[0] }
    let(:target_b) { targets[1] }
    let(:target_c) { targets[2] }
    before do
      Timecop.travel 1.month.ago do
        create(:call, :with_busy_target_status, page: page, target: target_a)
      end
      create_list(:call, 2, :with_busy_target_status, page: page, target: target_a)
      create(:call, :with_completed_target_status, page: page, target: target_a)
      create(:call, :with_completed_target_status, page: page, target: target_b)
    end

    describe "status_totals_by_target" do
      let(:data) { subject.to_h[:last_week][:target_calls][:status_totals_by_target] }
      it 'returns the right values' do
        target_a_row = data.find {|r| r['target_name'] == target_a.name }
        target_b_row = data.find {|r| r['target_name'] == target_b.name }
        target_c_row = data.find {|r| r['target_name'] == target_c.name }

        expect(target_a_row['busy']).to eql 2
        expect(target_a_row['completed']).to eql 1
        expect(target_b_row['completed']).to eql 1
        expect(target_c_row.slice(*CallTool::TargetCallsStats::STATUSES)).to be_empty
      end
    end

    describe 'status_totals' do
      let(:data) { subject.to_h[:last_week][:target_calls][:status_totals] }

      it 'returns the right values' do
        expect(data['completed']).to eql 2
        expect(data['busy']).to eql 2
        expect(data['no-answer']).to eql 0
        expect(data['failed']).to eql 0
      end
    end
  end
end
