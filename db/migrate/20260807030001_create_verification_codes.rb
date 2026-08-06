# frozen_string_literal: true

class CreateVerificationCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :verification_codes do |t|
      t.string :receiver, null: false
      t.string :channel, null: false
      t.string :code, null: false
      t.string :purpose, null: false, default: "login"
      t.integer :attempts, null: false, default: 0
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.timestamps
    end

    add_index :verification_codes, %i[receiver channel purpose]
  end
end
