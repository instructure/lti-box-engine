module LtiBoxEngine
  class User < ActiveRecord::Base
    belongs_to :lti_box_engine_account, :class_name => 'LtiBoxEngine::Account'

    def box_oauth_authorize_url
      self.update_attributes(box_oauth_state: SecureRandom.uuid)
      URI::HTTPS.build(
          host: 'www.box.com',
          path: '/api/oauth2/authorize',
          query: {
              response_type: 'code',
              client_id: BOX_CONFIG[:client_id],
              redirect_uri: BOX_CONFIG[:redirect_uri],
              state: self.box_oauth_state
          }.to_query
      ).to_s
    end

    def self.get_user_for_lti_launch(tp)
      User.where(lti_user_id: tp.user_id, tool_consumer_instance_guid: tp.tool_consumer_instance_guid)
    end

  end
end
