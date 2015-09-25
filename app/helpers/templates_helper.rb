# This is a module that checks if a widget we want to render is associated with an already saved campaign page.
# If it is, it returns the contents of that widget for rendering. If not - if it's called for a template preview,
# or when creating a new campaign page from scratch - it'll pass default content to be rendered for the widget.

module TemplatesHelper

  def build_options_hash(widget)
    # TODO: Once widgets belong to templates, remove first condition

    # if widget is in a template creation page
    if widget.class == WidgetType
      default_params(widget.widget_name)
    # if widget belongs to a campaign page that hasn't been saved yet
    elsif widget.page_id.nil?
      default_params(widget.widget_type.widget_name)
    # if widget belongs to a saved campaign page
    else
      widget.content
    end
  end

  def default_params(widget_type)
    default_widget_params = {
      image: {
        'width' => 640,
        'height' => 480,
        'image_url' => 'https://placeimg.com/640/480/any'
      },
      text_body: {
        'text_body_html' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec pretium sem.'
      },
      thermometer: {
        'goal' => 10000,
        'count' => 0,
        'autoincrement' => true,
        'linked_actions' => [1, 2, 3]
      },
      petition_form: {
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
      },
      raw_html: {
        'html' => '<span>This is some raw HTML</span>'
      }
    }
    
    default_widget_params[widget_type.to_sym]

  end
end
