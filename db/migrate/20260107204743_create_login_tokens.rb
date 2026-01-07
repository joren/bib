class CreateLoginTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end
    add_index :login_tokens, :token_digest, unique: true
    add_index :login_tokens, [:token_digest, :expires_at]
  end
end
