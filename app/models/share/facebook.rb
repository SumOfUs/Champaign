# frozen_string_literal: true
# == Schema Information
#
# Table name: share_facebooks
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  image       :string
#  button_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  page_id     :integer
#  share_count :integer
#  click_count :integer
#  sp_id       :string
#  image_id    :integer
#

class Share::Facebook < ApplicationRecord
  include Share::Variant

  validates :description, :title, presence: true
  belongs_to :image
end
