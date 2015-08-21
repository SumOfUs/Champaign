class Form < ActiveRecord::Base
  has_many :form_elements

  validates :name, presence: true

end
