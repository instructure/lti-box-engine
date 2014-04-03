class UpdateLtiBoxEngineLtiLaunches < ActiveRecord::Migration
  def change
    add_column :lti_box_engine_lti_launches, :token, :string
    add_column :lti_box_engine_lti_launches, :token_timestamp, :datetime
  end
end
