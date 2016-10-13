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

  validate :choices_is_valid

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
    choice
  ).freeze
  validates :data_type, inclusion: { in: VALID_TYPES }

  def liquid_data
    return attributes.symbolize_keys unless data_type == 'choice'
    attributes.symbolize_keys.merge(choices: formatted_choices)
  end

  def formatted_choices
    return [] if choices.blank?
    choices.map do |choice|
      if choice.class == String
        { label: choice, value: choice, id: choice_id(choice) }
      elsif choice.class == Hash
        choice.symbolize_keys.merge(id: choice_id(choice['value']))
      else
        choice
      end
    end
  end

  def choices_is_valid
    return if choices.nil?
    if choices.class != Array
      errors.add(:choices, 'must be an array of options')
      return
    end
    choices.each do |choice|
      if choice.class == Hash
        if !choice.key?('label') || !choice.key?('value')
          errors.add(:choices, 'must have a label and value for each dictionary option')
          break
        end
      elsif choice.class == String
        next
      else
        errors.add(:choices, 'must be an array containing strings or dictionaries')
        break
      end
    end
  end

  private

  def choice_id(choice)
    "#{name}_#{choice}".gsub(/[^a-z0-9_ ]/i, '').gsub(/[ _]+/, '_').underscore
  end

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
