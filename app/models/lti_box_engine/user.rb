module LtiBoxEngine
  class User < ActiveRecord::Base
    belongs_to :account
    has_many :lti_launches

    scope :by_tool_provider, ->(tp) {
      where(lti_user_id: tp.user_id, tool_consumer_instance_guid: tp.tool_consumer_instance_guid)
    }

    def create_lti_launch_from_tool_provider(tp)
      lti_launches.create(
          nonce: tp.request_oauth_nonce,
          request_oauth_timestamp: Time.at(tp.request_oauth_timestamp.to_i),
          payload: tp.to_params
      )
    end


  end
end
