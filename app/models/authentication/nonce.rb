# frozen_string_literal: true

class Authentication::Nonce < ApplicationRecord
  self.table_name = 'authentication_nonces'
  validates :nonce, presence: true, uniqueness: true
end
