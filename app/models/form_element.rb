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
#  choices       :jsonb
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
    email
    phone
    postal
    country
    dropdown
    choice
    checkbox
    instruction
    hidden
  ).freeze
  validates :data_type, inclusion: { in: VALID_TYPES }

  def liquid_data
    return attributes.symbolize_keys unless data_type == 'choice' || data_type == 'dropdown'
    attributes.symbolize_keys.merge(choices: formatted_choices)
  end

  def formatted_choices
    return [] if choices.blank?
    choices.map do |choice|
      if choice.is_a? String
        { label: choice, value: choice, id: choice_id(choice) }
      elsif choice.is_a? Hash
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
      if choice.is_a? Hash
        if !choice.key?('label') || !choice.key?('value')
          errors.add(:choices, 'must have a label and value for each dictionary option')
          break
        end
      elsif choice.is_a? String
        next
      else
        errors.add(:choices, 'must be an array containing strings or dictionaries')
        break
      end
    end
  end

  def can_destroy?
    if form.try(:formable).try(:required_form_elements).try(:include?, id)
      errors.add(:base, "is required for this #{form.formable.class.name.demodulize}")
      false
    else
      true
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

  def field_prefix(data_type)
    case data_type
    when 'paragraph', 'text'
      'action_textentry_'
    when 'checkbox'
      'action_box_'
    when 'dropdown'
      'action_dropdown_'
    when 'choice'
      'action_choice_'
    else
      'action_'
    end
  end

  def set_name
    unless name.blank? || ActionKitFields::ACTIONKIT_FIELDS_WHITELIST.include?(name)
      if !(name =~ ActionKitFields::VALID_PREFIX_RE) && !(name =~ /^(action_)+$/)
        self.name = field_prefix(data_type) + name
      end
    end
  end
end
