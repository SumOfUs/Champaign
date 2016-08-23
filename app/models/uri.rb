# frozen_string_literal: true
class Uri < ActiveRecord::Base
  belongs_to :page

  validates :domain, allow_nil: false, format: { with: /\A.+\..+\z/i }
  validates :path, allow_nil: false, format: { with: /\A\/.*\z/i }
  validates :page, presence: true

  before_validation :format_path

  private

  def format_path
    self.path = '/' if path.blank?
    self.path = "/#{path}" if path.first != '/'
  end
end
