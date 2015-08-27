class FormElement < ActiveRecord::Base
  belongs_to :form

  validates :name, :label, :data_type, presence: true

  before_validation :set_name
  before_validation :set_position, on: :create


  private

  def set_name
    return if label.empty?

    self.name = label.
      strip.
      gsub(/\s+/, ' ').
      gsub(/\s/, '_').
      downcase
  end

  def set_position
    last_position = (form.form_elements.maximum(:position) || -1) + 1
    self.position = last_position
  end
end
