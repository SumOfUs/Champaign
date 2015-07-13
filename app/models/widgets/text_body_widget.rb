class TextBodyWidget < Widget
  validates :content, presence: true, json: { schema: self.json_schema, message: ->(errors) { errors } }
end
