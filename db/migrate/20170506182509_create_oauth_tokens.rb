class CreateOauthTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :oauth_tokens do |t|
      t.integer :configured_service_id, null: false
      t.index :configured_service_id, unique: true
      t.text :access_token, null: false
      t.timestamp :expires_at, null: false

      t.timestamps
    end
  end
end
