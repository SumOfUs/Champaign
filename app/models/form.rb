class Form < ActiveRecord::Base
  has_many :form_elements, -> { order(:position) }

  scope :hidden,  -> { where(visible: false) }
  scope :visible, -> { where(visible: true) }

  validates :name, presence: true
end
