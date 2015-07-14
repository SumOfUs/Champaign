class ThermometerWidget < Widget
  store_accessor :content, [self.load_schema.keys.map(&:to_sym)]
  validates :content, presence: true, json: { schema: self.json_schema, message: ->(errors) { errors } }
end