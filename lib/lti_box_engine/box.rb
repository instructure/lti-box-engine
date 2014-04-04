module LtiBoxEngine
  class Box

    def oauth_url(client_id, redirect_uri, state)
      URI::HTTPS.build(
        host: 'www.box.com',
        path: '/api/oauth2/authorize',
        query: {
          response_type: 'code',
          client_id: client_id,
          redirect_uri: redirect_uri,
          state: state
        }.to_query
      ).to_s
    end

  end
end