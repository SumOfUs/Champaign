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
#  visible       :boolean          default(FALSE)
#  master        :boolean          default(FALSE)
#  formable_id   :integer
#  formable_type :string
#

class Form < ActiveRecord::Base
  # DEFAULT_ constants are used for building an initial, default
  # form. See service class +DefaultFormBuilder+.
  #
  DEFAULT_NAME = 'Basic'

  DEFAULT_FIELDS = [
    { label: 'form.default.email',   name: 'email',   required: true,  data_type: 'email'   },
    { label: 'form.default.name',    name: 'name',    required: true,  data_type: 'text'    },
    { label: 'form.default.country', name: 'country', required: true,  data_type: 'country' },
    { label: 'form.default.postal',  name: 'postal',  required: false, data_type: 'postal'  }
  ].freeze

  has_paper_trail on: [:update, :destroy]
  has_many :form_elements, -> { order(:position) }, dependent: :destroy
  belongs_to :formable, polymorphic: true, touch: true

  after_touch do
    formable.try(:page) do |page|
      page.touch if page
    end
  end

  scope :masters, -> { where(master: true) }

  validates :name, presence: true

  validate :name_is_unique

  def name_is_unique
    return unless master?

    errors.add(:name, 'must be unique') if Form.masters.where(name: name).any?
  end
end
