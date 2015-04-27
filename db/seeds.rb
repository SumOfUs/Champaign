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
  language = Languages.create!({language_code: 'EN/US', language_name: 'American English'})

# 3  make campaigns
  campaign = Campaigns.create!({campaign_name: 'Test campaigns'})

# 4. make widget types

  widget_type = WidgetTypes.create!({
      widget_name: 'test_widget',
      specifications: {
        'height': 'integer',
        'width': 'integer'
      },
      partial_path: '/test_widget',
      form_partial_path: '/form/test_widget',
      action_table_name: 'test_widget_results',
      active: false
    })

# 5. make a campaigns page
  campaign_page = CampaignPages.create!({
      language_id: language.id,
      actionkit_page_id: actionkit_page.id,
      title: 'Test campaigns page',
      slug: 'test_campaign_page',
      active: false,
      featured: false
    })

# 6. make campaigns pages widgets
  campaign_page_widget = CampaignPagesWidgets.create!()
# 7. make actionkit pages

# 8. make members 

actionkit_page_type = ActionkitPageType.create(actionkit_page_type: "petition")
actionkit_page = ActionkitPage.create({campaign_page_id: 1234567890, actionkit_page_type_id: 2468})
