require_relative '../../../queue_listeners/lib/actionkit_page_parser'
require_relative '../../../queue_listeners/lib/crm_page'

describe ActionkitPageParser do

  it 'should correctly parse AK JSON' do
    test_json = '{
    "actions": "/rest/v1/importaction/?page=3308",
    "allow_multiple_responses": true,
    "created_at": "2015-05-25T19:22:51",
    "default_source": "",
    "fields": {},
    "followup": null,
    "goal": null,
    "goal_type": "actions",
    "hidden": false,
    "hosted_with": "/rest/v1/hostingplatform/1/",
    "id": 3308,
    "language": "/rest/v1/language/100/",
    "list": "/rest/v1/list/1/",
    "multilingual_campaign": null,
    "name": "controlshift-company-stop-selling-bee-killing-pestices-11",
    "never_spam_check": false,
    "notes": "",
    "recognize": "once",
    "required_fields": [],
    "resource_uri": "/rest/v1/importpage/3308/",
    "status": "active",
    "subscribe": true,
    "tags": [
        {
            "name": "ControlShift",
            "resource_uri": "/rest/v1/tag/1405/"
        },
        {
            "name": "sumofus ControlShift",
            "resource_uri": "/rest/v1/tag/1406/"
        }
    ],
    "title": "ControlShift: COMPANY: Stop selling bee-killing pestices",
    "type": "Import",
    "unsubscribe": false,
    "unsubscribe_all": false,
    "updated_at": "2015-05-25T19:22:51",
    "url": ""
}'
    parser = ActionkitPageParser.new
    page = CrmPage.new
    page.id = 3308
    page.hidden = false
    page.status = 'active'
    page.language = '/rest/v1/language/100/'
    page.title = 'ControlShift: COMPANY: Stop selling bee-killing pestices'
    page.resource_uri = '/rest/v1/importpage/3308/'
    page.type = 'Import'
    page.name = 'controlshift-company-stop-selling-bee-killing-pestices-11'
    expect(parser.parse_from_actionkit(test_json)).to eq(page)
  end
end