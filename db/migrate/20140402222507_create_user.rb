class CreateUser < ActiveRecord::Migration
  def change
    create_table :lti_box_engine_users do |t|
      t.string :tool_consumer_instance_guid
      t.string :lti_id
      t.string :box_oauth_state
    end
  end
end
