require 'spec_helper'

module LtiBoxEngine
  describe Client do
    before(:each) do
      @client = Client.new
    end

    describe "#authorize!" do
      let(:mock_request) { Hash.new }

      before(:each) do
        @tp = IMS::LTI::ToolProvider.new('key', 'secret', {})
        IMS::LTI::ToolProvider.stub(:new).and_return(@tp)
        @tp.stub(:valid_request?).and_return(true)
        @tp.stub(:request_oauth_timestamp).and_return(Time.now)
        @tp.stub(:request_oauth_nonce).and_return('ABCDE')
        @tp.stub(:to_params).and_return({ foo: 'bar' })
      end

      it "with an invalid request" do
        @tp.stub(:valid_request?).and_return(false)
        result = @client.authorize!(mock_request)
        expect(result).to be_false
        expect(@client.error_message).to eq("The OAuth signature was invalid")
      end

      it "with expired request" do
        @tp.stub(:request_oauth_timestamp).and_return(Time.now - 2.hours)
        result = @client.authorize!(mock_request)
        expect(result).to be_false
        expect(@client.error_message).to eq("Your request is too old.")
      end

      it "with already existing nonce" do
        LtiLaunch.create_from_tp(@tp)
        expect(@client.authorize!(mock_request)).to be_false
        expect(@client.error_message).to eq("Nonce has already been used.")
      end

      it "with valid request" do
        result = @client.authorize!(mock_request)
        expect(result).to eq(@tp)
      end
    end
  end
end