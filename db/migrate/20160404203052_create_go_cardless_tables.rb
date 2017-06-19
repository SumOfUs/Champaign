# frozen_string_literal: true

class CreateGoCardlessTables < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_go_cardless_customers do |t|
      t.string :go_cardless_id
      t.string :email
      t.string :given_name
      t.string :family_name
      t.string :postal_code
      t.string :country_code
      t.string :language

      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end

    create_table :payment_go_cardless_payment_methods do |t|
      t.string :go_cardless_id
      t.string :reference
      t.string :scheme
      t.date   :next_possible_charge_date

      t.references :customer, references: :payment_go_cardless_customer, index: true

      t.timestamps null: false
    end
    add_foreign_key :payment_go_cardless_payment_methods, :payment_go_cardless_customers, column: :customer_id

    create_table :payment_go_cardless_subscriptions do |t|
      t.string :go_cardless_id
      t.decimal :amount
      t.string :currency
      t.integer :status
      t.string :name
      t.string :payment_reference

      t.references :page, index: true, foreign_key: true
      t.references :action, index: true, foreign_key: true
      t.references :payment_method, references: :payment_go_cardless_payment_method, index: true
      t.references :customer, references: :payment_go_cardless_customer, index: true

      t.timestamps null: false
    end
    add_foreign_key :payment_go_cardless_subscriptions, :payment_go_cardless_customers, column: :customer_id
    add_foreign_key :payment_go_cardless_subscriptions, :payment_go_cardless_payment_methods, column: :payment_method_id

    create_table :payment_go_cardless_transactions do |t|
      t.string :go_cardless_id
      t.date :charge_date
      t.decimal :amount
      t.string :description
      t.string :currency
      t.integer :status
      t.string :reference
      t.decimal :amount_refunded

      t.references :page, index: true, foreign_key: true
      t.references :action, index: true, foreign_key: true
      t.references :payment_method, references: :payment_go_cardless_payment_method, index: true
      t.references :customer, references: :payment_go_cardless_customer, index: true

      t.timestamps null: false
    end
    add_foreign_key :payment_go_cardless_transactions, :payment_go_cardless_customers, column: :customer_id
    add_foreign_key :payment_go_cardless_transactions, :payment_go_cardless_payment_methods, column: :payment_method_id
  end
end
