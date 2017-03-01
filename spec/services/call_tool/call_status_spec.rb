require 'rails_helper'

describe CallTool::CallStatus do
  def status_for(call)
    CallTool::CallStatus.for(call)
  end

  let!(:call) { build(:call, created_at: Time.now) }

  it 'returns the last event status' do
    call.member_call_events = [{}, { 'CallStatus' => 'answered' }]
    expect(status_for(call)).to eq 'answered'
  end

  context 'given no Twilio event has been recorded yet' do
    it "returns 'connecting' if within time threshold" do
      expect(status_for(call)).to eq 'connecting'
    end

    it "returns 'timed_out' more than 15 seconds have passed" do
      Timecop.travel 20.seconds.from_now
      expect(status_for(call)).to eq 'timed_out'
    end
  end
end
