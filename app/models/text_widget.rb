class TextWidget < Widget
  validates :content, presence: true, json: { schema: self.json_schema }
end
