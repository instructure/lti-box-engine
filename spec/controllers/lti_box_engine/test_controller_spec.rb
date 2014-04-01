require 'spec_helper'

module LtiBoxEngine
  describe TestController do

    describe "GET 'backdoor'" do
      it "returns http success" do
        get 'backdoor', use_route: :lti_box_engine
        response.should be_success
      end
    end

  end
end
