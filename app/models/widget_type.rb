class WidgetType < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :widget_name, :specifications
  # validating presence of a boolean field 'active'
  validates_inclusion_of :active, in: [true, false]
  has_and_belongs_to_many :templates

  # Specifies where this widget type's form partial is stored in the project.
  # Used with a render call to specify where the file should be loaded
  # Forms are intended to be used for editing or creating widgets.
  def form_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/form.slim"
  end

  # Specifies where this widget type's display partial is stored in the project.
  # Used with a render call to specify where the file should be loaded
  # Display partials are intented to be used for displaying the content stored in
  # a widget.
  def display_partial_path
    "widgets/#{self.widget_name.parameterize.underscore}/display.slim"
  end
end
