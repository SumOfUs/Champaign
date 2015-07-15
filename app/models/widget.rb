class Widget < ActiveRecord::Base

  belongs_to :page, polymorphic: true

  validates :page_display_order, presence: true, numericality: { only_integer: true, greater_than: 0 }

  TYPES = %w(TextBodyWidget PetitionWidget ImageWidget ThermometerWidget RawHtmlWidget)
  validates :type, presence: true, inclusion: TYPES

  validate :restrict_content_keys
  before_validation :cast_json_types

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

  # all user submitted values come in as strings on params, so we have to cast
  # them so that we can use all of PG's sweet json searching. on regular relational
  # fields, rails takes care of this for you, but not in json fields.
  def cast_json_types
    if content.present?
      schema = self.class.load_schema
      content.each_key do |key|
        next unless schema.has_key? key
        case schema[key]['type']
        when 'string'
          self.content[key] = content[key].to_s
        when 'integer'
          self.content[key] = content[key].to_i
        when 'float'
          self.content[key] = content[key].to_f
        when 'dictionary'
          self.content[key] = content[key].to_h
        when 'array'
          self.content[key] = content[key].to_a
        when 'boolean'
          self.content[key] = ActiveRecord::Type::Boolean.new.type_cast_from_user(content[key])
        end
      end
    end
  end

  def snake_type
    type.underscore
  end

  def self.snake_type
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
    "widgets/#{self.snake_type}/fields"
  end

  def self.json_schema
    Rails.root.join('db','json',"#{self.snake_type}.json_schema").to_s
  end

end
