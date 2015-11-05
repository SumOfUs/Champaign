require 'rails_helper'

describe AkidParser do
  let(:valid_string) {'14203.7145943.Si3iNO'}
  let(:valid_mailing_id) {'14203'}
  let(:valid_akid) {'7145943'}
  let(:invalid_string) {'Not a valid akid'}
  let(:valid_return) { {mailing_id: valid_mailing_id, actionkit_user_id: valid_akid}}
  let(:invalid_return) { {mailing_id: nil, actionkit_user_id: nil} }

  it 'validates the provided akid before working on it' do
    expect(AkidParser.new(invalid_string).invalid?).to eq(true)
    expect(AkidParser.parse(invalid_string)).to eq(invalid_return)
  end

  it 'correctly parses a valid akid' do
    expect(AkidParser.parse(valid_string)).to eq(valid_return)
  end

end