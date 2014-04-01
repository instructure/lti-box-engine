require_dependency "lti_box_engine/application_controller"
require "ims/lti"
require "oauth/request_proxy/rack_request"

module LtiBoxEngine
  class LtiController < ApplicationController

    def picker
    end

    def index
      @client = Client.new
      @tp = @client.authorize!(request, params)
      if @tp
        @lti_launch = LtiLaunch.create_from_tp(@tp)
      else
        # handle invalid auth
        @message = @client.error_message
        render :error
      end
    end

    def embed
      item = params[:item]
      lti_launch = LtiLaunch.where(id: params[:lti_launch_id]).first
      launch_params = lti_launch.payload

      tp = IMS::LTI::ToolProvider.new(nil, nil, launch_params)
      tp.extend IMS::LTI::Extensions::Content::ToolProvider

      if tp.accepts_content?
        if tp.accepts_url?
          redirect_url = tp.url_content_return_url(item['url'], item['name'], item['name'])
          render json: { redirect_url: redirect_url } and return
        else
          render text: 'Unsupported content type', status: 500
        end
      else
        render text: 'Unable to embed content', status: 500
      end
    end

    def xml_config
      host = "#{request.protocol}#{request.host_with_port}"
      url = "#{host}#{root_path}"
      title = "Box"
      tool_id = "lti_box_engine"
      tc = IMS::LTI::ToolConfig.new(:title => title, :launch_url => url)
      tc.extend IMS::LTI::Extensions::Canvas::ToolConfig
      tc.description = "Embed files from Box.net"
      tc.canvas_privacy_anonymous!
      tc.canvas_domain!(request.host)
      tc.canvas_icon_url!("#{host}/assets/lti_box_engine/icon.png")
      tc.canvas_text!(title)
      tc.set_ext_param('canvas.instructure.com', :tool_id, tool_id)
      tc.canvas_homework_submission!(enabled: true)
      tc.canvas_editor_button!(enabled: true)
      tc.canvas_resource_selection!(enabled: true)
      tc.canvas_course_navigation!(enabled: true)
      tc.canvas_user_navigation!(enabled: true)
      render xml: tc.to_xml
    end

    def health_check
      head 200
    end
  end
end
