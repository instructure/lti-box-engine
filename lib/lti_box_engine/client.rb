require 'ims/lti'

module LtiBoxEngine
  class Client

    attr_accessor :error_message

    def initialize
      @error_message = nil
    end

    def register_error(message)
      @error_message = message
    end

    def self.box_url_to_box_embed_url(url)
      embed_id = url.strip.split('/').last
      "https://app.box.com/embed_widget/s/#{embed_id}?view=list&sort=name&direction=ASC&theme=blue"
    end

    def authorize!(request, account)
      @error_message = nil
      key = request.params['oauth_consumer_key']
      secret = account ? account.secret : nil
      tp = IMS::LTI::ToolProvider.new(key, secret, request.params)

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
