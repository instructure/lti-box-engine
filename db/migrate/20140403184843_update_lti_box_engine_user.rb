class UpdateLtiBoxEngineUser < ActiveRecord::Migration
  def change
    add_column :lti_box_engine_users, :access_token, :string
    add_column :lti_box_engine_users, :refresh_token, :string
    add_column :lti_box_engine_users, :account_id, :integer
    rename_column :lti_box_engine_users, :lti_id, :lti_user_id
    remove_column :lti_box_engine_users, :box_oauth_state, :string
  end
end
