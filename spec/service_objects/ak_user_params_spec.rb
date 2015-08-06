require 'browser'

describe AkUserParams do
  before :all do
    $browser = Browser.new
  end

  let(:petition_signature) {{
    signature: {
      name: Faker::Name.name,
      email: Faker::Internet.email,
      state: Faker::Address.state,
      country: Faker::Address.country,
      postal: Faker::Address.postcode,
      address: Faker::Address.street_address,
      state: Faker::Address.state,
      city: Faker::Address.city,
      phone: Faker::PhoneNumber.phone_number,
      zip: Faker::Address.zip,
      region: Faker::Config.locale,
      lang: 'En'
      # email
      # name
      # name gets split to prefix, first name, middle name, last name and suffix automagically by AK ...
      # address1
      # address2
      # city
      # state
      # zip
      # postal
      # country
      # region
      # phone
      # mailing_id
      # id
      # plus4
      # lang
      # source
    }
  }}

  it 'Builds an object containing data about the user and the action' do
    expect(AkUserParams.create(petition_signature)).to eq(true)
  end
end