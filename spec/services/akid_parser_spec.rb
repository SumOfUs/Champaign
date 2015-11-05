require 'rails_helper'

describe AkidParser do
  let(:valid_mailing_id) {'14203'}
  let(:valid_actionkit_user_id) {'7145943'}
  let(:valid_akid) {"#{valid_mailing_id}.#{valid_actionkit_user_id}.Si3iNO"}
  let(:valid_return) { {mailing_id: valid_mailing_id, actionkit_user_id: valid_actionkit_user_id}}
  let(:invalid_return) { {mailing_id: nil, actionkit_user_id: nil} }

  it 'correctly parses a valid akid' do
    expect(AkidParser.new(valid_akid).invalid?).to eq false
    expect(AkidParser.parse(valid_akid)).to eq(valid_return)
  end

  it 'is invalid if akid is an actionkit_user_id' do
    invalid_akid = valid_actionkit_user_id
    expect(AkidParser.new(invalid_akid).invalid?).to eq true
    expect(AkidParser.parse(invalid_akid)).to eq invalid_return
  end

  it "is invalid if akid has only one period" do
    invalid_akid = "#{valid_mailing_id}1#{valid_actionkit_user_id}.Si3iNO"
    expect(AkidParser.new(invalid_akid).invalid?).to eq true
    expect(AkidParser.parse(invalid_akid)).to eq invalid_return
  end

  it 'is invalid if it has 3 periods' do
    invalid_akid = "#{valid_mailing_id}.#{valid_actionkit_user_id}.Si3.NO"
    expect(AkidParser.new(invalid_akid).invalid?).to eq true
    expect(AkidParser.parse(invalid_akid)).to eq invalid_return
  end


end