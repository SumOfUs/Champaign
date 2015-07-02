class TextWidget < Widget
  JSON_SCHEMA = Rails.root.join('db','json','text_widget.json_schema').to_s
  validates :content, presence: true, json: { schema: JSON_SCHEMA, options: { strict: true } }
end
