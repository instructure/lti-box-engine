class CreateLtiBoxEngineAccounts < ActiveRecord::Migration
  def change
    create_table :lti_box_engine_accounts do |t|
      t.string :name
      t.string :oauth_key
      t.string :oauth_secret
      t.timestamps
    end
  end
end
