describe AkUserParams do

  let(:params) { build(:petition_signature_params ) }
  let(:browser) { Browser.new }
  let(:expected_object) {
    (params[:signature].clone).merge({
                                         user_agent: browser.user_agent,
                                         browser_detected: browser.known?,
                                         mobile: browser.mobile?,
                                         tablet: browser.tablet?,
                                         platform: browser.platform
                                     })
  }

  it 'Builds an object containing data about the user and the action' do
    expect(AkUserParams.create(params, browser)).to eq(expected_object)
  end

end
