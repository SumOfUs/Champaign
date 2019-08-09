# == Schema Information
#
# Table name: pension_funds
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(TRUE), not null
#  country_code :string           not null
#  email        :string
#  fund         :string           not null
#  name         :string           not null
#  uuid         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_pension_funds_on_country_code  (country_code)
#  index_pension_funds_on_uuid          (uuid) UNIQUE
#

class PensionFund < ApplicationRecord
  has_paper_trail

  validates :country_code, presence: true

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    allow_blank: true
  }

  validates :fund, presence: true
  validates :name, presence: true

  scope :sorted,               -> { order('country_code, created_at') }
  scope :sorted_by_created_at, -> { order('created_at') }
  scope :active,               -> { where(active: true) }

  before_create :set_uuid

  def self.list(params = {})
    country_code = (params[:country] || params[:country_code])
    search_keys  = Array.new(3) do
      '%' + params[:search_text].to_s.downcase.strip + '%'
    end

    arel = PensionFund.all
    arel = arel.where(country_code: country_code.to_s.upcase) if country_code.present?

    if params[:search_text].present?
      arel = arel.where('LOWER(fund) like ? OR LOWER(email) like ? or LOWER(name) LIKE ?', *search_keys)
    end
    arel
  end

  def self.filter_by_country_code(country_code)
    PensionFund.select('uuid, fund, name, email, country_code').where(country_code: country_code.to_s.strip)
  end

  private

  def set_uuid
    return uuid if uuid.present?

    self.uuid = SecureRandom.uuid.delete('-')
  end
end
