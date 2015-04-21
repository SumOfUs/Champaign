class WidgetType < ActiveRecord::Base
  attr_accessor :widget_name, :specifications, :partial_path, :form_partial_path, :active
end