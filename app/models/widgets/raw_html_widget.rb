class RawHtmlWidget < Widget
  extend StoreWith.model

  validates :html, presence: true

  store_with :content do
    html :string
  end
end
