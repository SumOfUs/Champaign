describe TemplatesHelper do
  expected_image_hash = {'width' => 640, 'height' => 480, 'image_url' => 'https://placeimg.com/640/480/any'}
  expected_text_body_hash = {'text_body_html' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec pretium sem.'}
  expected_petition_form_hash = {
    'petition_text' => 'Please sign the petition!',
    'require_full_name' => true,
    'require_email_address' => true,
    'require_state' => false,
    'require_country' => true,
    'require_postal_code' => false,
    'require_address' => false,
    'require_city' => false,
    'require_phone' => false,
    'checkboxes' => [],
    'select_box' => {},
    'comment_textarea' => '',
    'call_in_form' => {},
    'letter_sent_form' => {},
    'form_button_text' => 'Add your voice!'
  }

  describe 'build_options_hash' do
    it 'returns a default hash when given a widget type' do
      wt = WidgetType.new widget_name: 'image'
      expect(helper.build_options_hash(wt)).to eq(expected_image_hash)

      wt = WidgetType.new widget_name: 'text_body'
      expect(helper.build_options_hash(wt)).to eq(expected_text_body_hash)

      wt = WidgetType.new widget_name: 'petition_form'
      expect(helper.build_options_hash(wt)). to eq(expected_petition_form_hash)
    end

    it 'returns a default hash when given an empty widget' do
      wt = WidgetType.new widget_name: 'image'
      widget = CampaignPagesWidget.new widget_type: wt
      expect(helper.build_options_hash(widget)).to eq(expected_image_hash)

      wt = WidgetType.new widget_name: 'text_body'
      widget = CampaignPagesWidget.new widget_type: wt
      expect(helper.build_options_hash(widget)).to eq(expected_text_body_hash)

      wt = WidgetType.new widget_name: 'petition_form'
      widget = CampaignPagesWidget.new widget_type: wt
      expect(helper.build_options_hash(widget)).to eq(expected_petition_form_hash)
    end

    it 'returns the correct contents when it is attached to a campaign_page' do
      wt = WidgetType.new widget_name: 'image'
      widget = CampaignPagesWidget.new widget_type: wt, campaign_page_id: 1, content: {image_url: 'test'}
      expect(helper.build_options_hash(widget)). to eq({'image_url' => 'test'})

      wt = WidgetType.new widget_name: 'text_body'
      widget = CampaignPagesWidget.new widget_type: wt, campaign_page_id: 1, content: {text_body_html: 'test'}
      expect(helper.build_options_hash(widget)).to eq({'text_body_html' => 'test'})

      wt = WidgetType.new widget_name: 'petition_form'
      widget = CampaignPagesWidget.new widget_type: wt, campaign_page_id: 1, content: {require_full_name: false}
      expect(helper.build_options_hash(widget)).to eq({'require_full_name' => false})
    end
  end
end
