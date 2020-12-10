# frozen_string_literal: true

# == Schema Information
#
# Table name: languages
#
#  id            :integer          not null, primary key
#  code          :string           not null
#  name          :string           not null
#  created_at    :datetime
#  updated_at    :datetime
#  actionkit_uri :string
#

class Language < ApplicationRecord
  has_paper_trail on: %i[update destroy]
  has_many :pages

  validates :code, :actionkit_uri, :name, presence: true, allow_blank: false
end
