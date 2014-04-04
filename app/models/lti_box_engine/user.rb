module LtiBoxEngine
  class User < ActiveRecord::Base
    belongs_to :lti_box_engine_account, :class_name => 'LtiBoxEngine::Account'

    def self.get_or_create_user_for_lti_launch(tp)
      unless user = User.where(lti_user_id: tp.user_id, tool_consumer_instance_guid: tp.tool_consumer_instance_guid).first
        user = User.create(lti_user_id: tp.user_id, tool_consumer_instance_guid: tp.tool_consumer_instance_guid)
      end
      user
    end

  end
end
