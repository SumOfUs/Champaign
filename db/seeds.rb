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
  language = Language.create!({language_code: 'EN/US', language_name: 'American English'})

# 3  make campaigns
  campaign = Campaign.create!({campaign_name: 'Test campaigns'})

# 4. make widget types - think of moving the partial path information into the model

  WidgetType.create!([
    {
      widget_name: 'text_body',
      specifications: {
        text_body_html: 'string'
      },
      partial_path: 'widgets/text_body/display.slim',
      form_partial_path: 'widgets/text_body/form.slim',
      action_table_name: nil,
      active: true
    },
    {
      widget_name: 'image',
      specifications: {
        width: 'integer',
        height: 'integer'
      },
      partial_path: 'widgets/image/display.slim',
      form_partial_path: 'widgets/image/form.slim',
      active: true
    },
    {
      widget_name: 'petition',
      specifications: {
        petition_text: 'string',
        # building petition forms is kind of an art of its own - I'm not sure what specifications to add
      },
      partial_path: 'widgets/image/display.slim',
      form_partial_path: 'widgets/image/form.slim',
      active: true
    },
    {
      widget_name: 'donation',
      specifications: {
        # a hash containing location / currency / multiplier for the donation amounts
        currencies_and_multipliers: {

        },
      },
      partial_path: 'widgets/donation/display.slim',
      form_partial_path: 'widgets/donation/form.slim',
      active: true
    }
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

  campaign_page_widget = campaign_page.campaign_pages_widget.create!({
    widget_type_id: (WidgetType.find_by widget_name: 'text_body').id,
    content: {text_body_html: "<p>Sign this petition to save the jumping spiders!</p>"},
    page_display_order: 1,
  })

# 7. create an actionkit page match for the campaign page widget
  campaign_page_widget.create_actionkit_page({actionkit_id: 123, actionkit_page_type_id: (ActionkitPageType.find_by actionkit_page_type: 'petition').id})

# 8. make members 