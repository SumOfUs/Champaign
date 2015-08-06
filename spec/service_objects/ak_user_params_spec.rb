describe AkUserParams do

  let(:params) {{
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
    }
  }}
  let(:browser) { Browser.new }
  let(:expected_object) {
    (params[:signature].clone).merge({
                                         user_agent: "",
                                         browser_detected: false,
                                         mobile: false,
                                         tablet: false,
                                         platform: :other
                                     })
  }

  it 'Builds an object containing data about the user and the action' do
    expect(AkUserParams.create(params,browser)).to eq(expected_object)
  end
end
