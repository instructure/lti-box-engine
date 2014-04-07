module RubyBox
  class Session
    #Monkey Patch for state inclusion
    #See https://github.com/attachmentsme/ruby-box/commit/8011efaff6bc397e48de60fbeced43951b95d758
    def authorize_url(redirect_uri, state=nil)
      opts = { :redirect_uri => redirect_uri }
      opts[:state] = state if state

      @oauth2_client.auth_code.authorize_url(opts)
    end
  end
end
