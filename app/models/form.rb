# frozen_string_literal: true

# == Schema Information
#
# Table name: forms
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  visible       :boolean          default("false")
#  master        :boolean          default("false")
#  formable_id   :integer
#  formable_type :string
#  position      :integer          default("0"), not null
#

class Form < ApplicationRecord
  has_paper_trail on: %i[update destroy]
  has_many :form_elements, -> { order(:position) }, dependent: :destroy
  belongs_to :formable, polymorphic: true, touch: true

  after_touch do
    formable.try(:page) do |page|
      page&.touch
    end
  end

  scope :masters, -> { where(master: true) }

  validates :name, presence: true
  validate :name_is_unique

  def name_is_unique
    return unless master?

    errors.add(:name, 'must be unique') if Form.masters.where(name: name).any?
  end

  def element_names
    form_elements.map(&:name).map(&:to_sym)
  end
end
