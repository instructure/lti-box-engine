require 'spec_helper'

module LtiBoxEngine
  describe Box do

    it "create the box oauth url" do
      client_id = 'client_id'
      redirect_url = 'https://test.app/redirect'
      state = 'state_code'
      expect(subject.oauth_url(client_id, redirect_url, state)).to eq 'https://www.box.com/api/oauth2/authorize?client_id=client_id&redirect_uri=https%3A%2F%2Ftest.app%2Fredirect&response_type=code&state=state_code'
    end

  end
end