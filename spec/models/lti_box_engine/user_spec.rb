require 'spec_helper'

module LtiBoxEngine
  describe User do

    describe ".get_user_for_launch" do
      it "finds a user based on the tool_consumer_instance_guid and user_id" do
        user = User.create!(tool_consumer_instance_guid: 'instance_guid', lti_user_id: 'user_id')
        tp = double(tool_consumer_instance_guid: 'instance_guid', user_id: 'user_id')

        expect(User.get_or_create_user_for_lti_launch(tp)).to eq user
      end

      it "creates a user based on the tool consumer instance_gui and user_id" do
        tp = double(tool_consumer_instance_guid: 'instance_guid', user_id: 'user_id')
        user = User.get_or_create_user_for_lti_launch(tp)
        expect(user.tool_consumer_instance_guid).to eq 'instance_guid'
        expect(user.lti_user_id).to eq 'user_id'
      end

    end

  end
end
