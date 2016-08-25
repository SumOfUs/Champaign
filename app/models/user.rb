# frozen_string_literal: true
class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_paper_trail
end
