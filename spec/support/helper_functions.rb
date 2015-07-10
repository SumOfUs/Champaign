module HelperFunctions
  def create_petition_page
    language = create_stub_language
    page = create_stub_page(language)
    widget_type = create_widget_type
    create_template([widget_type])
    create_widget(widget_type, page, {redirect_location: 'www.google.com'}, 0)
    page
  end

  def create_stub_language
    Language.create! language_name: 'Test', language_code: 'ts'
  end

  def create_stub_page(language)
    CampaignPage.create!(
        title: 'test',
        slug: 'test',
        active: true,
        featured: false,
        language: language
    )
  end

  def create_widget_type
    WidgetType.create!(
        widget_name: 'petition_form',
        specifications: {foo: 'bar'},
        active: true
    )
  end

  def create_template(widget_types)
    Template.create! template_name: 'test', widget_types: widget_types
  end

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
      {tag_name: '*Welcome_Sequence', actionkit_uri: '/rest/v1/tag/1000/'},
      {tag_name: '#Animal_Rights', actionkit_uri: '/rest/v1/tag/944/'},
      {tag_name: '!French', actionkit_uri: '/rest/v1/tag/1130/'},
      {tag_name: '!German', actionkit_uri: '/rest/v1/tag/1132/'},
      {tag_name: '#Net_Neutrality', actionkit_uri: '/rest/v1/tag/1078/'},
      {tag_name: '*FYI_and_VIP', actionkit_uri: '/rest/v1/tag/980/'},
      {tag_name: '@Germany', actionkit_uri: '/rest/v1/tag/1036/'},
      {tag_name: '!English', actionkit_uri: '/rest/v1/tag/1282/'},
      {tag_name: '@NewZealand', actionkit_uri: '/rest/v1/tag/1140/'},
      {tag_name: '@France', actionkit_uri: '/rest/v1/tag/1128/'},
      {tag_name: '#Sexism', actionkit_uri: '/rest/v1/tag/1208/'},
      {tag_name: '#Disability_Rights', actionkit_uri: '/rest/v1/tag/1040/'},
      {tag_name: '@Austria', actionkit_uri: '/rest/v1/tag/1042/'}
    ])
  end
end
