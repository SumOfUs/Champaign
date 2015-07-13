class Widget < ActiveRecord::Base

  belongs_to :page, polymorphic: true

  validates :page_display_order, presence: true, numericality: { only_integer: true, greater_than: 0 }

  TYPES = %w(TextBodyWidget PetitionWidget ImageWidget ThermometerWidget RawHtmlWidget)
  validates :type, presence: true, inclusion: TYPES

  validate :restrict_content_keys

  def restrict_content_keys
    if content.present?
      acceptable_keys = self.class.load_schema.keys
      content.each_key do |key|
        unless acceptable_keys.include? key
          errors.add(:content, "has unknown key '#{key}'")
        end
      end
    end
  end

  def type
    self.class.type
  end

  def self.type
    self.name.underscore
  end

  def self.types
    TYPES
  end

  def self.classes
    TYPES.map(&:constantize)
  end

  def self.title
    self.name.titleize
  end

  def self.load_schema
    @full_schema ||= JSON.parse File.read(self.json_schema)
    return @full_schema["properties"]
  end

  def self.fields
    "widgets/#{self.type}/fields"
  end

  def self.json_schema
    Rails.root.join('db','json',"#{self.type}.json_schema").to_s
  end

end
