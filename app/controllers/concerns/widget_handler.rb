# Image widget concern - contains the logic for getting contents for the image widget out of the form
require 'active_support/concern'

module WidgetHandler

  extend ActiveSupport::Concern

  include ImageWidget
  include PetitionWidget

  def self.build_widget_attributes(params, widgets)
    # Collects all widgets that were associated with the campaign page that was created,
    # then loops through them to build an array of widgets for that page that can be used to
    # create entries in the campaign_pages_widgets table through nested attributes when creating
    # the campaign page. 

    # The widgets' content is pulled from the data entered to the forms for the widgets, and their page display 
    # order is the order in which they were laid out in the creation form.

    widget_params = params[:widgets]
    widget_attributes = []

    widget_params.each_with_index do |(widget_type_name, widget_data), index|
      puts 'index', index
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type

      case widget_type_name 
        when 'petition'
          PetitionWidget.handle(widget_data, params)
        when 'image'
          ImageWidget.handle(widget_data, params)
      end
      
      widget_object = {
        widget_type_id: widget_type_id,
        content: widget_data,
      }

      # if an existing collection of widgets hasn't been passed,
      # create a widget_attributes hash for CREATING a page
      if widgets.nil?
        widget_object[:page_display_order] = index
      else
        # match the widget form with the existing widget in the 
        # array of widgets that was passed for the campaign page update call
        # -> NOTE - display order will need to be passed as addition to
        # widget type id if we will ever enable having two same widgets on a page
        widget = widgets.find_by(widget_type_id: widget_type_id)
        widget_object[:id] = widget.id
        widget_object[:page_display_order] = widget.page_display_order
      end

      widget_attributes.push(widget_object)

    end
    return widget_attributes
  end
end
