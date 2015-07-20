class Widget < ActiveRecord::Base

  belongs_to :page, polymorphic: true

  # I think this should become +position+ - +page_display_order+ is a mouthfull
  validates :page_display_order, presence: true, numericality: { only_integer: true, greater_than: 0 }


  # Why not access underscore directly?
  def snake_type
    type.underscore
  end

  def self.snake_type
    self.name.underscore
  end

  def self.classes
    [TextBodyWidget, PetitionWidget, ImageWidget, ThermometerWidget, RawHtmlWidget]
  end

  def self.title
    self.name.titleize
  end

  def self.fields
    "widgets/#{self.snake_type}/fields"
  end
end
