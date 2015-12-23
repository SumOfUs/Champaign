class Form < ActiveRecord::Base
  has_paper_trail on: [:update, :destroy]
  has_many :form_elements, -> { order(:position) }

  scope :masters, -> { where(master: true) }

  validates :name, presence: true, uniqueness: true
end

