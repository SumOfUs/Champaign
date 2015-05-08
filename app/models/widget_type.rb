class WidgetType < ActiveRecord::Base

  validates_presence_of :widget_name, :specifications
  # validating presence of a boolean field 'active'
  validates_inclusion_of :active, in: [true, false]

  has_and_belongs_to_many :templates

  # This method builds the path to render the widget form partial for a particular widget
  # based on the name of that widget.
  def form_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/form.slim"
  end

  # This method builds the path to render the widget display partial for a particular widget
  # based on the name of that widget.
  def display_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/display.slim"
  end
end
