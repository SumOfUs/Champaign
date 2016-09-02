# frozen_string_literal: true
# == Schema Information
#
# Table name: form_elements
#
#  id            :integer          not null, primary key
#  form_id       :integer
#  label         :string
#  data_type     :string
#  default_value :string
#  required      :boolean
#  visible       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  position      :integer          default(0), not null
#

class FormElement < ActiveRecord::Base
  belongs_to :form, touch: true
  has_paper_trail

  before_validation :set_position, on: :create
  before_validation :set_name, on: :create

  validates :name, :label, :data_type, presence: true
  validates_with ActionKitFields

  # Array of possible field types.
  VALID_TYPES = %w(
    text
    paragraph
    checkbox
    email
    phone
    country
    postal
    hidden
    instruction
  ).freeze
  validates :data_type, inclusion: { in: VALID_TYPES }

  private

  def set_position
    last_position = (form.form_elements.maximum(:position) || -1) + 1
    self.position = last_position
  end

  def set_name
    unless name.blank? || ActionKitFields::ACTIONKIT_FIELDS_WHITELIST.include?(name)
      if !(name =~ ActionKitFields::VALID_PREFIX_RE) && !(name =~ /^(action_)+$/)
        self.name = if data_type == 'paragraph' || data_type == 'text'
                      "action_textentry_#{name}"
                    elsif data_type == 'checkbox'
                      "action_box_#{name}"
                    else
                      "action_#{name}"
                    end
      end
    end
  end
end
