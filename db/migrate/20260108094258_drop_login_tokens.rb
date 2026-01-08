class DropLoginTokens < ActiveRecord::Migration[8.1]
  def change
    drop_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end
  end
end
