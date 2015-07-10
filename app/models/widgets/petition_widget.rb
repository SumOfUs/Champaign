class PetitionWidget < Widget
  validates :content, presence: true, json: { schema: self.json_schema, message: ->(errors) { errors } }

  has_one :actionkit_page, foreign_key: :widget_id
end
