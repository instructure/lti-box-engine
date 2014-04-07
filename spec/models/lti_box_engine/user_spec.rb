require 'spec_helper'

module LtiBoxEngine
  describe User do

    describe "by_tool_provider" do
      it "finds a user based on the tool_consumer_instance_guid and user_id" do
        user = User.create!(tool_consumer_instance_guid: 'instance_guid', lti_user_id: 'user_id')
        tp = double(tool_consumer_instance_guid: 'instance_guid', user_id: 'user_id')

        expect(User.by_tool_provider(tp).first).to eq user
      end
    end

    describe '#create_lti_launch_from_tool_provider' do
      it 'creates a new lti_launch' do
        tp = double(
            request_oauth_timestamp: '1396370344',
            request_oauth_nonce: 'ABCDE',
            to_params: {foo: 'bar'}
        )

        subject.save

        lti_launch = subject.create_lti_launch_from_tool_provider(tp)

        expect(lti_launch.user).to eq subject
        expect(lti_launch.new_record?).to be_false
        expect(lti_launch.nonce).to eq(tp.request_oauth_nonce)
        expect(lti_launch.request_oauth_timestamp).to eq(Time.at(tp.request_oauth_timestamp.to_i))
        expect(lti_launch.payload).to eq(tp.to_params)
      end
    end

  end
end
