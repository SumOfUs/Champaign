# frozen_string_literal: true

class AddFormableToForms < ActiveRecord::Migration[4.2]
  def change
    add_reference :forms, :formable, polymorphic: true, index: true
  end
end
