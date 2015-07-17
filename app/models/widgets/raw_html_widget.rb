class RawHtmlWidget < Widget
  include StoreWith.model

  validates :html, presence: true

  store_with :content do
    html :string
  end
end
