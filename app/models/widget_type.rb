class WidgetType < ActiveRecord::Base

  validates_presence_of :widget_name, :specifications
  # validating presence of a boolean field 'active'
  validates_inclusion_of :active, in: [true, false]

  def form_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/form.slim"
  end

  def display_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/display.slim"
  end
end
