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

def create_widget(widget_type, page, content, page_display_order)
  CampaignPagesWidget.create!(
      widget_type: widget_type,
      content: content,
      campaign_page: page,
      page_display_order: page_display_order
  )
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
