require 'spec_helper'

module LtiBoxEngine
  describe User do
    describe "#box_oauth_authorize_url" do
      it "generates a url" do
        SecureRandom.stub(:uuid).and_return('random-uuid')
        url = URI.parse(subject.box_oauth_authorize_url)

        expect(url.scheme).to eq 'https'
        expect(url.host).to eq 'www.box.com'
        expect(url.path).to eq '/api/oauth2/authorize'
        expect(url.query).to include 'response_type=code'
        expect(url.query).to include 'client_id=box_client_id'
        expect(url.query).to include "redirect_uri=#{CGI.escape('/my/redirect/uri')}"
        expect(url.query).to include 'state=random-uuid'
      end

      it 'sets the box_oauth_state' do
        SecureRandom.stub(:uuid).and_return('random-uuid')
        url = URI.parse(subject.box_oauth_authorize_url)
        expect(subject.box_oauth_state).to eq 'random-uuid'
      end
    end

    describe ".get_user_for_launch" do
      it "finds a user based on the tool_consumer_instance_guid and user_id" do
        user = User.create!(tool_consumer_instance_guid: 'instance_guid', lti_id: 'user_id')
        tp = double(tool_consumer_instance_guid: 'instance_guid', user_id: 'user_id')

        expect(User.get_user_for_lti_launch(tp).first).to eq user
      end
    end

  end
end
