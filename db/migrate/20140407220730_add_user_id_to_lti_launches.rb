class AddUserIdToLtiLaunches < ActiveRecord::Migration
  def change
    add_column :lti_box_engine_lti_launches, :user_id, :integer
  end
end
