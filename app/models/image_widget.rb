class ImageWidget < Widget
  JSON_SCHEMA = Rails.root.join('db','json','image_widget.json_schema').to_s
  validates :content, presence: true, json: { schema: JSON_SCHEMA }
end
