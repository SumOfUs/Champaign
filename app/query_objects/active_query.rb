class ActiveQuery
  delegate :all, :each, :for_each, to: :active

  def initialize(model)
    @relation = model.where(active: true)
  end

  def active
    @relation
  end
end
