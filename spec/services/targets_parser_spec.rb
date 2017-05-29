# frozen_string_literal: true
require 'rails_helper'

describe CallTool::TargetsParser do
  let(:csv_string) do
    <<-EOS
      country        ,target phone,target phone extension ,target name  ,target title, caller id
      united kingdom ,4410000000  ,123                    ,Claire Do    ,MEP South East England, 1234567
      ``             ,4411111111  ,                       ,Emily Fred   ,MEP for South West England,
      ``             ,442222222   ,                       ,George Harris,MEP for South West England,
      germany        ,490000000   ,                       ,Abe Ben      ,MEP for Germany,
    EOS
  end

  let(:targets) { CallTool::TargetsParser.parse_csv(csv_string) }

  it 'returns 4 targets' do
    expect(targets.count).to eq(4)
  end

  it 'creates targets assigning the information properly' do
    t = targets.first
    expect(t.country_code).to eq('GB')
    expect(t.phone_number).to eq('4410000000')
    expect(t.phone_extension).to eq('123')
    expect(t.name).to eq('Claire Do')
    expect(t.title).to eq('MEP South East England')
    expect(t.caller_id).to eq('1234567')
  end

  it 'uses previous value for column when `` symbol is found' do
    t = targets[2]
    expect(t.country_code).to eq('GB')
  end
end
