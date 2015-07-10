class RawHtmlWidget < Widget
  validates :content, presence: true, json: { schema: self.json_schema }
end