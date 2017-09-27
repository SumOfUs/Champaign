# frozen_string_literal: true

require 'rails_helper'

describe CallTool::TargetsParser do
  let(:csv_string) do
    <<-EOS
      Country, State, phone number, Phone Extension, NAME, title, caller id, dynamic column
      united kingdom, Greater London, 4410000000, 123, Claire Do, MEP South East England, 1234567, Dynamic
      united kingdom, Greater London, 4411111111,, Emily Fred, MEP for South West England, 123
      united kingdom, Brighton and Hove, 442222222,, George Harris, MEP for South West England, 123
      germany, Berlin, 490000000,, Abe Ben, MEP for Germany, 5
    EOS
  end

  let(:targets) { CallTool::TargetsParser.parse_csv(csv_string) }

  it 'returns 4 targets' do
    expect(targets.count).to eq(4)
  end

  it 'creates targets assigning the information properly' do
    t = targets.first
    expect(t.name).to eq('Claire Do')
    expect(t.title).to eq('MEP South East England')
    expect(t.country_code).to eq('GB')
    expect(t.phone_number).to eq('+4410000000')
    expect(t.phone_extension).to eq('123')
  end

  it 'creates targets with extra properties in the fields hash' do
    t, = targets
    expect(t.fields[:state]).to eq('Greater London')
    expect(t.fields[:dynamic_column]).to eq('Dynamic')
  end
end
