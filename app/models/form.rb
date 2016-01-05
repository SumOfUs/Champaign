class Form < ActiveRecord::Base
  DEFAULT_NAME = 'Basic'

  has_paper_trail on: [:update, :destroy]
  has_many :form_elements, -> { order(:position) }

  scope :masters, -> { where(master: true) }

  validates :name, presence: true
  validate :name_is_unique


  def name_is_unique
    return unless master?

    if Form.masters.where(name: name).any?
      errors.add(:name, 'must be unique')
    end
  end
end

