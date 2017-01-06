# frozen_string_literal: true
require 'spec_helper'

describe CallTool::TargetsParser do
  let(:csv_string) do
    <<-EOS
      country        ,postal           ,target phone,target name  ,target title
      united kingdom ,1000--2000       ,440000000   ,Claire Do    ,MEP South East England
      ``             ,"A100--B200,C100",4411111111  ,Emily Fred   ,MEP for South West England
      ``             ,``               ,442222222   ,George Harris,MEP for South West England
      germany        ,                 ,490000000   ,Abe Ben      ,MEP for Germany
    EOS
  end

  let(:targets) { CallTool::TargetsParser.parse_csv(csv_string) }

  it 'returns 4 targets' do
    expect(targets.count).to eq(4)
  end

  it 'creates targets assigning the information properly' do
    t = targets.first
    expect(t.country_code).to eq('GB')
    expect(t.postal_code).to eq('1000--2000')
    expect(t.phone_number).to eq('440000000')
    expect(t.name).to eq('Claire Do')
    expect(t.title).to eq('MEP South East England')
  end

  it 'uses previous value for column when `` symbol is found' do
    t = targets[2]
    expect(t.country_code).to eq('GB')
    expect(t.postal_code).to eq('A100--B200,C100')
  end

  it 'leaves the field as nil if a blank column is found' do
    t = targets[3]
    expect(t.postal_code).to be_nil
  end
end
