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
end
