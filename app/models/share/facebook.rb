# frozen_string_literal: true
class Share::Facebook < ActiveRecord::Base
  include Share::Variant

  validates :description, :title, presence: true
  belongs_to :image
end

