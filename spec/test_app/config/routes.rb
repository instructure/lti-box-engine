Rails.application.routes.draw do

  mount LtiBoxEngine::Engine => "/lti_box_engine"
end
