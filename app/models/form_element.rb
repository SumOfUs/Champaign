class FormElement < ActiveRecord::Base
  belongs_to :form, touch: true
  has_paper_trail

  before_validation :set_position, on: :create
  before_validation :set_name, on: :create

  validates :name, :label, :data_type, presence: true
  validates_with ActionKitFields

  # Array of possible field types.
  VALID_TYPES = %w{
    text
    checkbox
    email
    phone
    country
    postal
  }

  private

  def set_position
    last_position = (form.form_elements.maximum(:position) || -1) + 1
    self.position = last_position
  end

  def set_name
    unless ActionKitFields::ACTIONKIT_FIELDS_WHITELIST.include?(name)
      self.name = "action_#{name}" unless name =~  ActionKitFields::VALID_PREFIX_RE
    end
  end
end

