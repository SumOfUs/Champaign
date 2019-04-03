# frozen_string_literal: true

module HelperFunctions
  def log_in
    email = 'test@sumofus.org'
    password = 'password'
    User.create! email: email, password: password
    visit '/users/sign_in'
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button 'Log in'
  end

  def create_tags
    Tag.create!([
      { tag_name: '*Welcome_Sequence', actionkit_uri: '/rest/v1/tag/1000/' },
      { tag_name: '#Animal_Rights', actionkit_uri: '/rest/v1/tag/944/' },
      { tag_name: '#Net_Neutrality', actionkit_uri: '/rest/v1/tag/1078/' },
      { tag_name: '*FYI_and_VIP', actionkit_uri: '/rest/v1/tag/980/' },
      { tag_name: '@Germany', actionkit_uri: '/rest/v1/tag/1036/' },
      { tag_name: '@NewZealand', actionkit_uri: '/rest/v1/tag/1140/' },
      { tag_name: '@France', actionkit_uri: '/rest/v1/tag/1128/' },
      { tag_name: '#Sexism', actionkit_uri: '/rest/v1/tag/1208/' },
      { tag_name: '#Disability_Rights', actionkit_uri: '/rest/v1/tag/1040/' },
      { tag_name: '@Austria', actionkit_uri: '/rest/v1/tag/1042/' }
    ])
  end

  def error_messages_from_response(response)
    JSON.parse(response.body)['errors'].inject([]) { |memo, error| memo << error['message'] }.uniq
  end
end
