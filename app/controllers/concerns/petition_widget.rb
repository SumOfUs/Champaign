# petition widget concern - contains the logic for getting contents for the petition widget out of the form
require 'active_support/concern'

module PetitionWidget
  
  extend ActiveSupport::Concern

  def self.handle(widget_data, params)
    # We have some placeholder data for checkboxes and textareas if we are using a
    # petition form. We need to remove those or we'll end up with phantom elements in our
    # form.
    if widget_data.key?('checkboxes') and widget_data['checkboxes'].key?('{cb_number}')
      widget_data['checkboxes'].delete('{cb_number}')
    end
    if widget_data.key?('textarea') and widget_data['textarea'].key?('placeholder')
      widget_data['textarea'].delete('placeholder')
    end
  end

end
