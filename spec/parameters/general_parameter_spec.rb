
# Since the tests for our Parameter types are all identical (make sure
# that they correctly filter the right values and throw errors on the
# wrong ones), we define a hash of all the different Parameter types
# that we're going to test and then loop over each of them, plugging
# in the relevant values.
widgets_attributes = [{
    id: 1,
    type: 'TextBodyWidget',
    _destroy: 'false',
    text_body_html: 'string'
  },{
    id: 2,
    type: 'RawHtmlWidget',
    _destroy: 'true',
    html: 'string'
  },{
    id: '3',
    type: 'ThermometerWidget',
    _destroy: 'false',
    goal: '500',
    count: '40',
    autoincrement: 'false'
  },{
    id: '40',
    type: 'PetitionWidget',
    _destroy: 'false',
    petition_text: "and so it was told",
    form_button_text: "that the children of the town",
    require_full_name: "false",
    require_email_address: "false",
    require_country: "false",
    require_state: "false",
    require_postal_code: "false",
    require_address: "false",
    require_city: "false",
    require_phone: "false",
    checkboxes: ["would", "live", "in", "nests"],
    select_box:       { nested_key: "nested_value" },
    comment_textarea: { nested_key: "nested_value" },
    call_in_form:     { nested_key: "nested_value" },
    letter_sent_form: { nested_key: "nested_value" }
  },{
    id: '3',
    type: 'ImageWidget',
    _destroy: 'false',
    image_attributes: { content: "" }
  }
]

parameter_classes_to_test = {
  actionkit_page_type: {
    class_type: ActionkitPageTypeParameters,
    correct_params: { 
      id: 1,
      actionkit_page_type: 'test'
    }
  },
  actionkit_page: {
    class_type: ActionkitPageParameters,
    correct_params: {
      id: 1,
      campaign_page_id: 1,
      actionkit_page_type_id: 'test'
    }
  },
  campaign_page: {
    class_type: CampaignPageParameters,
    correct_params: {
      id: 1,
      title: 'Awesome Campaign Page',
      slug: '/page/awesome-campaigns-page',
      active: true,
      featured: false,
      widgets_attributes: widgets_attributes
    }
  },
  campaign: {
    class_type: CampaignParameters,
    correct_params: {
      id: 1,
      campaign_name: 'My campaigns!'
    }
  },
  language: {
    class_type: LanguageParameters,
    correct_params: {
      id: 1,
      language_code: 'en',
      language_name: 'English'
    }
  },
  member: {
    class_type: MemberParameters,
    correct_params: {
      id: 1,
      email_address: 'notarealemail@notarealdomain.notarealtld',
      actionkit_member_id: '1234564sga'
    }
  },
  template: {
    class_type: TemplateParameters,
    correct_params: {
      id: 1,
      template_name: 'Awesome Template',
      active: false,
      widgets_attributes: widgets_attributes
    }
  },
  widget: {
    class_type: WidgetParameters,
    correct_params: {
      id: '40',
      type: 'PetitionWidget',
      _destroy: 'false',
      petition_text: "and so it was told",
      form_button_text: "that the children of the town",
      require_full_name: "false",
      require_email_address: "false",
      require_country: "false",
      require_state: "false",
      require_postal_code: "false",
      require_address: "false",
      require_city: "false",
      require_phone: "false",
      checkboxes: ["would", "live", "in", "nests"],
      select_box:       { nested_key: "nested_value" },
      comment_textarea: { nested_key: "nested_value" },
      call_in_form:     { nested_key: "nested_value" },
      letter_sent_form: { nested_key: "nested_value" }
    }
  }
}

# Here we do the actual looping with the repeated tests.

parameter_classes_to_test.each do |key, value|
  describe value[:class_type] do
    describe '.permit' do
      describe 'when permitted parameters' do
        it 'should permit actionkit_page_type' do
          page_params = value[:correct_params]
          params = ActionController::Parameters.new(key => page_params)
          permitted_params = value[:class_type].new(params).permit
          expect(permitted_params).to eq page_params.with_indifferent_access
        end
      end

      describe 'when unpermitted parameters' do
        it 'raises error' do
          page_params = {
              a_key_that_wil_seriously_never_get_used: 'a totally wrong value'
          }
          params = ActionController::Parameters.new(key => page_params)
          expect{ value[:class_type].new(params).permit }.
            to raise_error(ActionController::UnpermittedParameters)
        end
      end
    end
  end
end
