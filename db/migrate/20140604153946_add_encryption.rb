class AddEncryption < ActiveRecord::Migration

  def change
    change_table :lti_box_engine_users do |t|
      t.remove :refresh_token, :access_token

      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv
      t.string :encrypted_refresh_token_salt

      t.string :encrypted_access_token
      t.string :encrypted_access_token_iv
      t.string :encrypted_access_token_salt

      end
  end

end
