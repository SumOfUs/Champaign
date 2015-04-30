class WidgetType < ActiveRecord::Base

  validates_presence_of :widget_name, :specifications
  # validating presence of a boolean field 'active'
  validates_inclusion_of :active, in: [true, false]

  has_and_belongs_to_many :templates

  def form_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/form.slim"
  end

  def display_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/display.slim"
  end
end
