module LtiBoxEngine
  class LtiLaunch < ActiveRecord::Base
    serialize :payload, Hash
    before_save :update_token_timestamp

    class << self
      def valid_nonce?(nonce, min=60)
        nonce_ts = Time.now - (min * 60 * 60)
        where(nonce: nonce).where("request_oauth_timestamp >= ?", nonce_ts).count == 0
      end

      def cleanup!(num_days=3)
        where("request_oauth_timestamp <= ?", Time.now - num_days.days).destroy_all
      end

      def create_from_tp(tp)
        create(
          nonce: tp.request_oauth_nonce,
          request_oauth_timestamp: Time.at(tp.request_oauth_timestamp.to_i),
          payload: tp.to_params
        )
      end

      def get_user_for_lti_launch(tp)
        User.where(lti_id: tp.user_id, tool_consumer_instance_guid: tp.tool_consumer_instance_guid)
      end

      def get_by_token(token)
        if lti_launch = where(token:token).where("token_timestamp >= ?", 5.minutes.ago).first
          lti_launch.token = nil
          lti_launch.save
          lti_launch
        end
      end

    end

    def create_tool_provider
      tp = IMS::LTI::ToolProvider.new(nil, nil, self.payload)
      tp.extend IMS::LTI::Extensions::Content::ToolProvider
      tp
    end

    def generate_token
      self.token = SecureRandom.uuid
      self.save!
      self.token
    end

    private

    def update_token_timestamp
      if self.token != self.token_was
        self.token_timestamp = Time.now
      end
    end

  end
end
