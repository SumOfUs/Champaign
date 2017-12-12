class CreateAuthenticationNonces < ActiveRecord::Migration[5.1]
  def change
    create_table :authentication_nonces do |t|
      t.string :nonce
      t.timestamps
      t.index :nonce
    end
  end
end
