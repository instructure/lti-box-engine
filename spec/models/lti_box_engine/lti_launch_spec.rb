require 'spec_helper'

module LtiBoxEngine
  describe LtiLaunch do
    describe "#valid_nonce?" do
      it "with existing" do
        nonce = "ABCDE"
        ts = Time.now
        existing_lti_launch = LtiLaunch.create!({
          nonce: nonce,
          request_oauth_timestamp: ts
        })
        expect(LtiLaunch.valid_nonce?(nonce)).to be_false
      end

      it "with expired" do
        nonce = "ABCDE"
        ts = Time.now - 30.days
        existing_lti_launch = LtiLaunch.create!({
          nonce: nonce,
          request_oauth_timestamp: ts
        })
        expect(LtiLaunch.valid_nonce?(nonce)).to be_true
      end

      it "without existing" do
        nonce = "ABCDE"
        expect(LtiLaunch.valid_nonce?(nonce)).to be_true
      end
    end

    it "#cleanup" do
      LtiLaunch.create!({ request_oauth_timestamp: Time.now })
      5.times { LtiLaunch.create!({ request_oauth_timestamp: Time.now - 5.days }) }
      expect(LtiLaunch.count).to eq(6)
      LtiLaunch.cleanup!
      expect(LtiLaunch.count).to eq(1)
    end

    it "#create_from_tp" do
      tp = double({
        request_oauth_timestamp: '1396370344',
        request_oauth_nonce: 'ABCDE',
        to_params: { foo: 'bar' }
      })
      lti_launch = LtiLaunch.create_from_tp(tp)
      expect(lti_launch.new_record?).to be_false
      expect(lti_launch.nonce).to eq(tp.request_oauth_nonce)
      expect(lti_launch.request_oauth_timestamp).to eq(Time.at(tp.request_oauth_timestamp.to_i))
      expect(lti_launch.payload).to eq(tp.to_params)
    end
  end
end