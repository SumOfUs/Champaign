class CallTool::Target
  include ActiveModel::Model

  attr_accessor :country, :postal_code, :phone_number, :name, :title

  validates :country, presence: true

  def to_hash
    {
      country: country,
      postal_code: postal_code,
      phone_number: phone_number,
      name: name,
      title: title
    }
  end

end
