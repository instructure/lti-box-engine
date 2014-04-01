module LtiBoxEngine
  class LtiLaunch < ActiveRecord::Base
    serialize :payload, Hash

    class << self 
      def valid_nonce?(nonce, min=60)
        nonce_ts = Time.now - (min * 60 * 60)
        where(nonce: nonce).where("request_oauth_timestamp >= ?", nonce_ts).count == 0
      end

      def cleanup!(num_days=3)
        where("request_oauth_timestamp <= ?", Time.now - num_days.days).destroy_all
      end

      def create_from_tp(tp)
        create({
          nonce: tp.request_oauth_nonce,
          request_oauth_timestamp: Time.at(tp.request_oauth_timestamp.to_i),
          payload: tp.to_params
        })
      end
    end
  end
end
