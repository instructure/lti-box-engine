require 'spec_helper'

module LtiBoxEngine
  describe BoxOauthController do
    routes { LtiBoxEngine::Engine.routes }

    describe '#index' do
      let(:user) { User.new }
      let(:box_token) { double('token', refresh_token: 'refresh_token', token: 'access_token') }
      let(:box_session) { double('session', get_access_token: box_token) }

      before :each do
        LtiLaunch.stub(:get_by_token).and_return(double('lti_launch', generate_token: '', user: user))
        User.stub(:get_or_create_user_for_lti_launch).and_return (user)
        RubyBox::Session.stub(:new).and_return(box_session)
      end

      it 'redirects to lti_index' do
        LtiLaunch.stub(:get_by_token).and_return(double('lti_launch', generate_token: '4321dcba', user: user))
        response = get 'index', code: '123456abcdef', state: 'token'

        expect(LtiLaunch).to have_received(:get_by_token).with('token')
        expect(response).to redirect_to lti_index_path(token: '4321dcba')
      end

      it 'sets the users refresh, and access tokens' do
        response = get 'index', code: '123456abcdef', state: 'token'

        expect(user.refresh_token).to eq('refresh_token')
        expect(user.access_token).to eq('access_token')
        expect(box_session).to have_received(:get_access_token).with('123456abcdef')
      end

    end

  end
end