# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 1. make actionkit page types
actionkit_page_type = ActionkitPageType.create!({actionkit_page_type: 'petition'})

# 2. make languages
language = Language.create!({language_code: 'EN/US', language_name: 'English'})

# 3  make campaigns
campaign = Campaign.create!({campaign_name: 'Test campaign'})

# 4. make widget types

WidgetType.create!([
  {
    widget_name: 'image',
    specifications: {
      width: 'integer',
      height: 'integer',
      image_url: 'string'
    },
    active: true
  },
  {
    widget_name: 'petition_form',
    specifications: {
      petition_text: 'string',
      require_full_name: 'boolean',
      require_email_address: 'boolean',
      require_state: 'boolean',
      require_country: 'boolean',
      require_postal_code: 'boolean',
      require_address: 'boolean',
      require_city: 'boolean',
      require_phone: 'boolean',
      checkboxes: 'array',
      select_box: 'dictionary',
      comment_textarea: 'dictionary',
      call_in_form: 'dictionary',
      letter_sent_form: 'dictionary',
      form_button_text: 'string'
    },
    active: true
  },
  {
    widget_name: 'raw_html',
    specifications: {
      content: 'string'
    },
    active: true
  },
  {
    widget_name: 'thermometer',
    specifications: {
      goal: 'integer',
      autoincrement: 'boolean',
      # thermometers should have a way of storing action table IDs for the campaign_page_widgets that will be linked
      # to the thermometer, as a new way of linking several campaign pages to the same thermometer
      linked_actions: 'array',
      count: 'integer'
    },
    active: true,
  },
  {
    widget_name: 'text_body',
    specifications: {
      text_body_html: 'string'
    },
    action_table_name: nil,
    active: true
  },
])

# 5. make a campaign page

campaign_page = CampaignPage.create!({
  language_id: (Language.find_by language_code: 'EN/US').id,
  title: 'Test page',
  slug: 'test_name',
  active: false,
  featured: false
})

# 6. create a widget for the campaign page

campaign_page_widget = campaign_page.campaign_pages_widgets.create!({
  widget_type_id: (WidgetType.find_by widget_name: 'text_body').id,
  content: {text_body_html: "<p>Sign this petition to save the jumping spiders!</p>"},
  page_display_order: 1,
})

# 7. create an actionkit page match for the campaign page widget
campaign_page_widget.create_actionkit_page({actionkit_id: 123, actionkit_page_type_id: (ActionkitPageType.find_by actionkit_page_type: 'petition').id})

# 8. Create the tags and their associations to ActionKit

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
  {tag_name: '@Austria', actionkit_uri: '/rest/v1/tag/1042/'},
  {tag_name: '@Switzerland', actionkit_uri: '/rest/v1/tag/1043/'},
  {tag_name: '#Anti_Racism', actionkit_uri: '/rest/v1/tag/945/'},
  {tag_name: '#Consumer_Protection', actionkit_uri: '/rest/v1/tag/946/'},
  {tag_name: '#Economic_Justice', actionkit_uri: '/rest/v1/tag/941/'},
  {tag_name: '#Environment', actionkit_uri: '/rest/v1/tag/942/'},
  {tag_name: '#Food_and_GMOs', actionkit_uri: '/rest/v1/tag/940/'},
  {tag_name: '#Human_Rights_and_Civil_Liberties', actionkit_uri: '/rest/v1/tag/574/'},
  {tag_name: '#LGBT_Rights', actionkit_uri: '/rest/v1/tag/938/'},
  {tag_name: '#Media_Accountability', actionkit_uri: '/rest/v1/tag/937/'},
  {tag_name: '#Privatization_and_Political_Meddling', actionkit_uri: '/rest/v1/tag/947/'},
  {tag_name: '#Shareholder_Activism', actionkit_uri: '/rest/v1/tag/943/'},
  {tag_name: '#Womens_Rights', actionkit_uri: '/rest/v1/tag/934/'},
  {tag_name: '#Workers_Rights', actionkit_uri: '/rest/v1/tag/933/'},
  {tag_name: '*Petition', actionkit_uri: '/rest/v1/tag/971/'},
  {tag_name: '*Call-in', actionkit_uri: '/rest/v1/tag/973/'},
  {tag_name: '*Event', actionkit_uri: '/rest/v1/tag/976/'},
  {tag_name: '*Fundraiser', actionkit_uri: '/rest/v1/tag/972/'},
  {tag_name: '*Letters_or_Comments', actionkit_uri: '/rest/v1/tag/975/'},
  {tag_name: '*Other_High_Bar_Action', actionkit_uri: '/rest/v1/tag/977/'},
  {tag_name: '*Social_Media', actionkit_uri: '/rest/v1/tag/974/'},
  {tag_name: '+MVP', actionkit_uri: '/rest/v1/tag/948/'},
  {tag_name: '+Test', actionkit_uri: '/rest/v1/tag/947/'},
  {tag_name: '+Full_Universe', actionkit_uri: '/rest/v1/tag/951/'},
  {tag_name: '+Special_Universe', actionkit_uri: '/rest/v1/tag/964/'},
  {tag_name: '+Kicker', actionkit_uri: '/rest/v1/tag/952/'},
  {tag_name: '@Australia', actionkit_uri: '/rest/v1/tag/969/'},
  {tag_name: '@Canada', actionkit_uri: '/rest/v1/tag/967/'},
  {tag_name: '@Europe', actionkit_uri: '/rest/v1/tag/954/'},
  {tag_name: '@Global', actionkit_uri: '/rest/v1/tag/953/'},
  {tag_name: '@Multi_Country', actionkit_uri: '/rest/v1/tag/956/'},
  {tag_name: '@NorthAmerica', actionkit_uri: '/rest/v1/tag/955/'},
  {tag_name: '@Other_National', actionkit_uri: '/rest/v1/tag/970/'},
  {tag_name: '@UK', actionkit_uri: '/rest/v1/tag/968/'},
  {tag_name: '@USA', actionkit_uri: '/rest/v1/tag/966/'}
])

# 8. make members 
