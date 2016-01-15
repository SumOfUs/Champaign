class Form < ActiveRecord::Base

  # DEFAULT_ constants are used for building an initial, default
  # form. See service class +DefaultFormBuilder+.
  # 
  DEFAULT_NAME = 'Basic'

  DEFAULT_FIELDS = [
    { label: 'Email Address',  name: 'email',  required: true,  data_type: 'email'},
    { label: 'Full Name',      name: 'name',   required: true,  data_type: 'text' },
    { label: 'Postal Code',    name: 'postal', required: false, data_type: 'text' }
  ]

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

