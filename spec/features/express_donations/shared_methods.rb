module SharedMethods
  def register_member(member)
    visit new_member_authentication_path(follow_up_url: '/a/page', email: member.email)

    fill_in 'password', with: 'password'
    fill_in 'password_confirmation', with: 'password'
    click_button 'Register'
    expect(page).to have_content("window.location = '/a/page'")
  end

  def authenticate_member(auth)
    visit email_confirmation_path(token: auth.token, email: member.email)

    expect(page).to have_content('You have successfully confirmed your account')
    expect(auth.reload.confirmed_at).not_to be nil
  end

  def store_payment_in_vault(index = 1)
    params = {
      payment_method_nonce: 'fake-valid-nonce',
      recurring: false,
      amount: 1.00,
      currency: 'GBP',
      store_in_vault: true,
      user: {
        name: 'Foo Bar',
        email: email,
        country: 'US',
        postal: '12345',
        address1: 'The Avenue'
      }
    }

    cassette = 'feature_store_card_in_vault'
    cassette += "_#{index}" if index > 1

    VCR.use_cassette(cassette) do
      page.driver.post api_payment_braintree_transaction_path(donation_page.id), params
    end

    expect(JSON.parse(page.body)['success']).to eq(true)
  end

  def delete_cookies_from_browser
    page.driver.browser.clear_cookies
  end
end
