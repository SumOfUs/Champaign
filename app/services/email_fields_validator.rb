class EmailFieldsValidator
  include ActiveModel::Model
  attr_accessor :to_name, :to_email, :from_name, :from_email, :body, :subject

  validates :to_name, presence: true
  validates :to_email, presence: true, email: true
  validates :from_name, presence: true
  validates :from_email, presence: true, email: true
  validates :body, presence: true, length: { minimum: 100 }
  validates :subject, presence: true
end
