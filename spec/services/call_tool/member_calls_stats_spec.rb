require 'rails_helper'

describe CallTool::MemberCallsStats do
  let!(:page) { create(:page, :with_call_tool) }
  subject { CallTool::MemberCallsStats.new(Call.not_failed.where(page: page)) }

  describe '#status_totals_by_day'do
    let(:data) { subject.status_totals_by_day }

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

  describe '#status_totals_by_week' do
    let(:data) { subject.status_totals_by_week }
    before do
      create_list(:call, 2, :connected, page: page)
      Timecop.travel(2.weeks.ago) do
        create(:call, :started, page: page)
      end
    end

    it 'returns an array of 5 items (last 5 weeks)' do
      expect(data.count).to eq 5
    end

    it 'returns empty rows for weeks that had no calls' do
      expect(data[0]['date']).to eq 4.weeks.ago.beginning_of_week.to_date.to_s(:short)
      expect(data[0].slice('unstarted', 'started', 'connected', 'failed').values).to eq [0,0,0,0]
    end

    it 'returns the appropriate calls count for the weeks that had calls' do
      expect(data.last['date']).to eq Date.today.beginning_of_week.to_s(:short)
      expect(data.last['connected']).to eq 2

      expect(data[2]['date']).to eq 2.weeks.ago.to_date.beginning_of_week.to_s(:short)
      expect(data[2]['started']).to eq 1
    end
  end

  describe '#last_week_status_totals' do
    let(:data) { subject.last_week_status_totals }

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
end
