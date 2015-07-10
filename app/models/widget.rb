class Widget < ActiveRecord::Base

  belongs_to :page, polymorphic: true

  validates :page_display_order, presence: true, numericality: { only_integer: true, greater_than: 0 }

  types = %w(TextBodyWidget PetitionWidget ImageWidget ThermometerWidget RawHtmlWidget)
  validates :type, presence: true, inclusion: types

  validates :restrict_content_keys, json: { message: ->(errors) { errors } }

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

  def self.load_schema
    full_schema = JSON.parse File.read(self.json_schema)
    return full_schema["properties"]
  end

  def self.json_schema
    Rails.root.join('db','json',"#{self.name.underscore}.json_schema").to_s
  end

end
