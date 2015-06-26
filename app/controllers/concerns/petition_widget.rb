# Image widget concern - contains the logic for getting contents for the image widget out of the form
require 'active_support/concern'

module PetitionWidget
  extend ActiveSupport::Concern

  def self.handle(widget_data, params)
    if widget_data.key?('checkboxes') and widget_data['checkboxes'].key?('{cb_number}')
      widget_data['checkboxes'].delete('{cb_number}')
    end
    if widget_data.key?('textarea') and widget_data['textarea'].key?('placeholder')
      widget_data['textarea'].delete('placeholder')
    end
  end
  
end
