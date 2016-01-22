class AddFormableToForms < ActiveRecord::Migration
  def change
    add_reference :forms, :formable, polymorphic: true, index: true
  end
end
