class Form < ActiveRecord::Base
  has_many :form_elements, -> { order(:position) }

  scope :masters, -> { where(master: true) }

  validates :name, presence: true
end

