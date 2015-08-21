class FormElement < ActiveRecord::Base
  belongs_to :form

  validates :name, :label, :data_type, presence: true
end
