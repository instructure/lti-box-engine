require 'ims/lti'

module LtiBoxEngine
  class Client

    $oauth_creds = { "key" => "secret" }

    attr_accessor :error_message

    def initialize
      @error_message = nil
    end

    def register_error(message)
      @error_message = message
    end

    def authorize!(request, opts = {})
      @error_message = nil
      key = opts['oauth_consumer_key']
      tp = IMS::LTI::ToolProvider.new(key, $oauth_creds[key], opts)

      if !tp.valid_request?(request)
        register_error("The OAuth signature was invalid")
        return nil
      end

      if Time.now.utc.to_i - tp.request_oauth_timestamp.to_i > 60*60
        register_error("Your request is too old.")
        return nil
      end

      if !LtiLaunch.valid_nonce?(tp.request_oauth_nonce, 60)
        register_error("Nonce has already been used.")
        return nil
      end

      tp.extend IMS::LTI::Extensions::Content::ToolProvider

      return tp
    end

  end
end
