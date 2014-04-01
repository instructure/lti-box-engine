class CreateLtiBoxEngineLtiLaunches < ActiveRecord::Migration
  def change
    create_table :lti_box_engine_lti_launches do |t|
      t.string :nonce
      t.text :payload
      t.timestamp :request_oauth_timestamp

      t.timestamps
    end
  end
end
