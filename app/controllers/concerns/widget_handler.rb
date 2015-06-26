# Image widget concern - contains the logic for getting contents for the image widget out of the form
require 'active_support/concern'

module WidgetHandler

  extend ActiveSupport::Concern

  include ImageWidget
  include PetitionWidget

  def self.build_widget_attributes(params)
    # Collects all widgets that were associated with the campaign page that was created,
    # then loops through them to build an array of widgets for that page that can be used to
    # create entries in the campaign_pages_widgets table through nested attributes when creating
    # the campaign page. 

    # The widgets' content is pulled from the data entered to the forms for the widgets, and their page display 
    # order is the order in which they were laid out in the creation form.
    widgets = params[:widgets]
    widget_attributes = []
    i = 0
    widgets.each do |widget_type_name, widget_data|
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type

      case widget_type_name 
        when 'petition'
          PetitionWidget.handle(widget_data, params)
        when 'image'
          ImageWidget.handle(widget_data, params)
      end
      
      widget_attributes.push({widget_type_id: widget_type_id,
                                         content: widget_data,
                                         page_display_order: i})
      i += 1
    end

  return widget_attributes
  
  end
end
