# This is a module that checks if a widget we want to render is associated with an already saved campaign page.
# If it is, it returns the contents of that widget for rendering. If not - if it's called for a template preview,
# or when creating a new campaign page from scratch - it'll pass default content to be rendered for the widget.

module TemplatesHelper

  def build_options_hash(widget)
    # if widget is in a template creation page
    if widget.class == WidgetType
      default_params(widget.widget_name)
    # if widget belongs to a campaign page that hasn't been saved yet
    elsif widget.campaign_page_id.nil?
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
        'text_body_html' =>
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec pretium sem. Nullam sit amet gravida quam. Suspendisse egestas purus eu orci sollicitudin, eu ornare orci tincidunt. Nullam et lacus eu nunc malesuada efficitur. Aliquam erat volutpat. Donec consectetur quam a est imperdiet, id pulvinar massa interdum. Aenean porttitor ut risus ut efficitur. Quisque aliquam sapien id turpis placerat malesuada. Proin at mattis dui, a rutrum nisi. In tempor neque eu nisl pellentesque consectetur. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi tortor purus, condimentum eu vestibulum ut, blandit ac nisl. Sed laoreet consequat dui, vulputate sagittis est mollis a. Sed sagittis mattis arcu, quis efficitur nunc accumsan eu. Phasellus convallis ex et augue ullamcorper blandit.
        Praesent scelerisque metus sit amet fringilla tincidunt. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nunc tincidunt tortor a lacus commodo lacinia. Suspendisse non diam eu lectus bibendum sodales. Nam finibus elit sed orci malesuada, quis rhoncus urna fermentum. Nam faucibus nisi nulla, at rhoncus mauris auctor pellentesque. Suspendisse interdum metus arcu.
        Sed vitae magna ut urna auctor venenatis. Cras lacinia neque tortor, id gravida mauris laoreet vel. Phasellus dictum mattis interdum. Aenean et gravida dolor. Sed at luctus leo. Phasellus eu neque tortor. Aliquam sed felis bibendum, consequat eros sit amet, sagittis velit. Maecenas sed mi nulla. Donec tincidunt leo vitae nisi commodo, eget commodo mi scelerisque. Duis pretium nulla accumsan auctor finibus. Sed non tortor quis nisl ultricies hendrerit. Aliquam fringilla lorem eu interdum lacinia. Aliquam vel blandit orci. Fusce semper, lacus a iaculis sodales, ipsum est consequat nunc, eu porttitor nulla turpis vestibulum quam.
        Nullam sit amet augue augue. Donec porta eleifend est laoreet sollicitudin. Curabitur nec ligula vitae libero mollis vestibulum. Aenean mi lectus, molestie nec finibus sit amet, faucibus eget ante. Quisque mattis, diam ac aliquet commodo, sapien nisi accumsan ligula, nec consectetur lacus sapien sit amet eros. Proin vestibulum interdum lacus, egestas consequat lacus commodo et. Mauris scelerisque maximus arcu sed dapibus. Quisque non magna in urna suscipit dignissim sed at diam. Nullam sollicitudin massa urna, vel fringilla mauris lacinia vel. Mauris eu sapien rhoncus, congue velit sit amet, pellentesque felis.
        Sed porta rutrum gravida. Vestibulum eu sem eget dui finibus ultricies nec in orci. Aenean quam turpis, tristique nec arcu vitae, viverra pellentesque neque. Praesent vitae mauris felis. Phasellus eleifend vehicula ligula vitae gravida. Aliquam congue ultricies varius. Cras lorem risus, condimentum nec justo id, iaculis vestibulum lorem. Donec quis erat ac augue aliquet laoreet.'
      },
      thermometer: {
        'goal' => 10000,
        'count' => 0,
        'autoincrement' => false,
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
      }
    }
    
    default_widget_params[widget_type.to_sym]

  end
end
