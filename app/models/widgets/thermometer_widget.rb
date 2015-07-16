class ThermometerWidget < Widget
  extend StoreWith.model

  validates :goal, :count, presence: true

  store_with :content do
    goal          :integer
    count         :integer
    autoincrement :boolean
  end
end

