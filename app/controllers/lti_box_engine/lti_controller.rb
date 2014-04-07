require_dependency "lti_box_engine/application_controller"
require "ims/lti"
require "oauth/request_proxy/rack_request"
require "ruby-box"

module LtiBoxEngine
  class LtiController < ApplicationController

    def index
      if @lti_launch = LtiLaunch.get_by_token(params[:token])
        @tp = @lti_launch.create_tool_provider

        if @tp.accepts_content?
          if @tp.accepts_file?
            @link_type = "direct"
          else
            @link_type = "shared"
          end
        else
          # launched via navigation
          redirect_to "https://www.box.com/embed_widget/files/0/f/0"
        end
      else
        render status: :unauthorized
      end
    end

    def embed
      item = params[:item]
      lti_launch = LtiLaunch.where(id: params[:lti_launch_id]).first
      launch_params = lti_launch.payload

      tp = IMS::LTI::ToolProvider.new(nil, nil, launch_params)
      tp.extend IMS::LTI::Extensions::Content::ToolProvider

      if tp.accepts_content?
        if tp.accepts_file?(item['name']) && item['type'] != 'folder'
          redirect_url = tp.file_content_return_url(item['url'], item['name'])
          render json: {redirect_url: redirect_url} and return
        elsif tp.accepts_url?
          # The URL will be to a folder. We need to modify it to load the embed widget
          redirect_url = tp.url_content_return_url(Client.box_url_to_box_embed_url(item['url']), item['name'], item['name'])
          render json: {redirect_url: redirect_url} and return
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
      tc.canvas_selector_dimensions!(430, 200)
      render xml: tc.to_xml
    end

    def launch
      client = Client.new
      secret = Account.where(key: params[:oauth_consumer_key]).pluck(:secret).first
      if tp = client.authorize!(request, secret)
        lti_launch = LtiLaunch.create_from_tp(tp)
        token = lti_launch.generate_token
        user = User.get_or_create_user_for_lti_launch(tp)
        if user.refresh_token
          redirect_to lti_index_path(token: token)
        else
          redirect_to box_session.authorize_url(oauth2_url)
        end

      else
        # handle invalid auth
        @message = client.error_message
        render :error
      end
    end

    def health_check
      head 200
    end

  end
end
