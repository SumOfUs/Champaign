class ThermometerWidget < Widget
  include StoreWith.model

  validates :goal, presence: true, numericality: { greater_than: 0 }

  store_with :content do
    goal          :integer
    count         :integer
    autoincrement :boolean
  end
end

