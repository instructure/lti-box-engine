module LtiBoxEngine
  class Account < ActiveRecord::Base
    has_many :users
  end
end
