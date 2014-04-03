module LtiBoxEngine
  class Account < ActiveRecord::Base
    has_many :lti_box_engine_users, :class_name => 'LtiBoxEngine::User'
  end
end
