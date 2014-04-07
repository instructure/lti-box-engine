module LtiBoxEngine
  class BoxOauthController < ApplicationController

    def index
      state = params[:state]

      launch = LtiLaunch.get_by_token(state)
      user = launch.user

      #make call to get tokens
      oauth2_token = box_session.get_access_token(params[:code])

      user.refresh_token = oauth2_token.refresh_token
      user.access_token = oauth2_token.token
      user.save

      redirect_to lti_index_path(token: launch.generate_token)
    end

  end
end
