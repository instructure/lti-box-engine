require 'spec_helper'

module LtiBoxEngine
  describe LtiLaunch do
    describe "#valid_nonce?" do
      it "with existing" do
        nonce = "ABCDE"
        ts = Time.now
        existing_lti_launch = LtiLaunch.create!(
          nonce: nonce,
          request_oauth_timestamp: ts
        )
        expect(LtiLaunch.valid_nonce?(nonce)).to be_false
      end

      it "with expired" do
        nonce = "ABCDE"
        ts = Time.now - 30.days
        existing_lti_launch = LtiLaunch.create!(
          nonce: nonce,
          request_oauth_timestamp: ts
        )
        expect(LtiLaunch.valid_nonce?(nonce)).to be_true
      end

      it "without existing" do
        nonce = "ABCDE"
        expect(LtiLaunch.valid_nonce?(nonce)).to be_true
      end
    end

    it "#cleanup" do
      LtiLaunch.create!({request_oauth_timestamp: Time.now})
      5.times { LtiLaunch.create!({request_oauth_timestamp: Time.now - 5.days}) }
      expect(LtiLaunch.count).to eq(6)
      LtiLaunch.cleanup!
      expect(LtiLaunch.count).to eq(1)
    end

    it "#create_from_tp" do
      tp = double(
        request_oauth_timestamp: '1396370344',
        request_oauth_nonce: 'ABCDE',
        to_params: {foo: 'bar'}
      )
      lti_launch = LtiLaunch.create_from_tp(tp)
      expect(lti_launch.new_record?).to be_false
      expect(lti_launch.nonce).to eq(tp.request_oauth_nonce)
      expect(lti_launch.request_oauth_timestamp).to eq(Time.at(tp.request_oauth_timestamp.to_i))
      expect(lti_launch.payload).to eq(tp.to_params)
    end

    it "#create_tool_provider" do
      lti_launch = LtiLaunch.create!(
        nonce: 'ABCDE',
        request_oauth_timestamp: Time.now
      )
      expect(lti_launch.create_tool_provider).to be_a_kind_of IMS::LTI::ToolProvider

    end

    it "updates the #token_timestamp when setting #token=" do
      lti_launch = LtiLaunch.create!(
        nonce: 'ABCDE',
        request_oauth_timestamp: Time.now
      )
      ts = Time.parse("Feb 24 1981")
      Time.stub(:now).and_return(ts)
      lti_launch.token = 'abc123'
      lti_launch.save!
      expect(lti_launch.token_timestamp).to eq ts
    end

    it "#generate_token" do
      SecureRandom.stub(:uuid).and_return('abc123')
      lti_launch = LtiLaunch.create!(
        nonce: 'ABCDE',
        request_oauth_timestamp: Time.now
      )
      expect(lti_launch.generate_token).to eq 'abc123'
    end


    it "clears token after looking up" do
      token = LtiLaunch.create!(
        nonce: 'ABCDE',
        request_oauth_timestamp: Time.now
      ).generate_token
      lti_launch = LtiLaunch.get_by_token(token)
      expect(lti_launch.token).to be_nil
    end

  end
end