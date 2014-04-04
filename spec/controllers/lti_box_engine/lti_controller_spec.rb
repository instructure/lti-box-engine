require 'spec_helper'

module LtiBoxEngine
  describe LtiController do
    routes { LtiBoxEngine::Engine.routes }

    describe "GET 'index'" do
      it "returns http success" do
        lti_launch = LtiLaunch.create!(
          nonce: "ABCDE",
          request_oauth_timestamp: Time.now,
          payload: {foo: 'bar'}
        )
        tp = double(
          :accepts_content? => true,
          :accepts_file? => false,
          :url_content_return_url => '/return/url',
          :file_content_return_url => '/return/file'

        )
        LtiLaunch.any_instance.stub(:create_tool_provider).and_return(tp)
        token = lti_launch.generate_token
        get 'index', token: token
        expect(response).to be_success
      end

      it "returns http 401" do
        get 'index'
        expect(response.code).to eq "401"
      end

    end

    describe "GET config" do
      it "should generate a valid xml cartridge" do
        request.stub(:env).and_return({
                                        "SCRIPT_NAME" => "/lti_box_engine",
                                        "rack.url_scheme" => "http",
                                        "HTTP_HOST" => "test.host",
                                        "PATH_INFO" => "/lti_box_engine"
                                      })
        get 'xml_config'
        expect(response.body).to include('<blti:title>Box</blti:title>')
        expect(response.body).to include('<blti:description>Embed files from Box.net</blti:description>')
        expect(response.body).to include('<lticm:property name="text">Box</lticm:property>')
        expect(response.body).to include('<lticm:property name="tool_id">lti_box_engine</lticm:property>')
        expect(response.body).to include('<lticm:property name="icon_url">http://test.host/assets/lti_box_engine/icon.png</lticm:property>')
        expect(response.body).to include('<lticm:options name="homework_submission">')
        expect(response.body).to include('<lticm:options name="editor_button">')
        expect(response.body).to include('<lticm:options name="resource_selection">')
        expect(response.body).to include('<lticm:options name="course_navigation">')
        expect(response.body).to include('<lticm:options name="user_navigation">')
      end
    end

    describe "POST 'embed'" do
      let(:lti_launch) {
        LtiLaunch.create!(
          nonce: "ABCDE",
          request_oauth_timestamp: Time.now,
          payload: {foo: 'bar'}
        )
      }

      let(:item) {
        {
          url: '/some/url',
          name: 'file name',
          type: 'file'
        }
      }

      before :each do
        @tp = double(
          :accepts_content? => true,
          :url_content_return_url => '/return/url',
          :file_content_return_url => '/return/file'

        )
        IMS::LTI::ToolProvider.stub(:new).and_return(@tp)
      end

      context "accepts file" do
        before :each do
          @tp.stub(:accepts_file?).and_return(true)
          @tp.stub(:accepts_url?).and_return(false)
        end

        it "should return redirect url for file" do
          item['type'] = 'file'
          post 'embed', lti_launch_id: lti_launch.id, item: item

          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['redirect_url']).to eq '/return/file'
        end

        it "should return 500 error when filetype is not accepted" do
          @tp.stub(:accepts_file?).with('photo.poo').and_return(false)
          item['name'] = 'photo.poo'
          post 'embed', lti_launch_id: lti_launch.id, item: item

          expect(response.status).to eq 500
          expect(response.body).to eq("Unsupported content type")
        end
      end

      context "accepts url" do
        before :each do
          @tp.stub(:accepts_file?).and_return(false)
          @tp.stub(:accepts_url?).and_return(true)
        end

        it "should return redirect url for url when item type is folder" do
          @tp.stub(:accepts_file?).and_return(true)
          item['type'] = 'folder'
          post 'embed', lti_launch_id: lti_launch.id, item: item

          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['redirect_url']).to eq '/return/url'
        end

        it "should return redirect url for url when tp does not accept file" do
          post 'embed', lti_launch_id: lti_launch.id, item: item

          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['redirect_url']).to eq '/return/url'
        end
      end

      it "should return a 500 error if tp doesn't accept content" do
        @tp.stub(:accepts_content?).and_return(false)
        post 'embed', lti_launch_id: lti_launch.id

        expect(response.status).to eq 500
        expect(response.body).to eq 'Unable to embed content'
      end

      it "should return a 500 error if tp doesn't accept url or file" do
        @tp.stub(:accepts_url?).and_return(false)
        @tp.stub(:accepts_file?).and_return(false)
        post 'embed', lti_launch_id: lti_launch.id, item: item

        expect(response.status).to eq 500
        expect(response.body).to eq 'Unsupported content type'
      end

    end

    describe '#launch' do

      it 'renders an error if lti auth fails' do
        response = post 'launch'
        expect(response.code).to render_template(:error)
      end

      it 'redirects to lti index' do
        Client.any_instance.stub(:authorize!).and_return true
        LtiLaunch.stub(:create_from_tp).and_return(double('lti_launch', generate_token: 'token'))

        response = post 'launch'
        expect(response).to redirect_to(lti_index_path(token: 'token'))

      end

    end

  end
end
