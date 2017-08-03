# frozen_string_literal: true

require 'rails_helper'

describe EmailTool::TargetsParser do
  let(:csv_string) do
    <<-EOS
      name, email, country
      John Doe, john@gmail.com, United States
      Patrick Watson, patrick@gmail.com, France
    EOS
  end

  let(:targets) { EmailTool::TargetsParser.parse_csv(csv_string) }

  it 'returns 2 targets' do
    expect(targets.count).to eq(2)
  end

  it 'creates targets assigning the information properly' do
    t = targets.first
    expect(t.name).to eq('John Doe')
    expect(t.email).to eq('john@gmail.com')
  end

  it 'creates targets with extra properties in the fields hash' do
    t = targets.first
    expect(t.fields[:country]).to eq('United States')
  end
end
