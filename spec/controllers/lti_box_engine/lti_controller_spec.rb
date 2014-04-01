require 'spec_helper'

module LtiBoxEngine
  describe LtiController do

    describe "GET 'index'" do
      it "returns http success" do
        get 'index', use_route: :lti_box_engine
        response.should be_success
      end
    end

    describe "GET config" do
      it "should generate a valid xml cartridge" do
        request.stub(:env).and_return({
          "SCRIPT_NAME"     => "/lti_box_engine",
          "rack.url_scheme" => "http",
          "HTTP_HOST"       => "test.host",
          "PATH_INFO"       => "/lti_box_engine"
        })
        get 'xml_config', use_route: :lti_box_engine
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
        LtiLaunch.create!({
          nonce: "ABCDE",
          request_oauth_timestamp: Time.now,
          payload: { foo: 'bar' }
        })
      }

      let(:item) {
        {
          url: '/some/url',
          name: 'file name'
        }
      }

      before :each do
        @tp = double({
          :accepts_content? => true,
          :accepts_url? => true,
          :url_content_return_url => '/return/url'
        })
        IMS::LTI::ToolProvider.stub(:new).and_return(@tp)
      end

      it "should return a 500 error if tp doesn't accept content" do
        @tp.stub(:accepts_content?).and_return(false)
        post 'embed', lti_launch_id: lti_launch.id, use_route: :lti_box_engine

        expect(response.status).to eq 500
        expect(response.body).to eq 'Unable to embed content'
      end

      it "should return a 500 error if tp doesn't accept url" do
        @tp.stub(:accepts_url?).and_return(false)
        post 'embed', lti_launch_id: lti_launch.id, item: item, use_route: :lti_box_engine

        expect(response.status).to eq 500
        expect(response.body).to eq 'Unsupported content type'
      end

      it "should return redirect url" do
        post 'embed', lti_launch_id: lti_launch.id, item: item, use_route: :lti_box_engine

        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['redirect_url']).to eq '/return/url' 
      end
    end

  end
end
