module LtiBoxEngine
  class Account < ActiveRecord::Base
    scope :by_auth, -> (k, s) { where(oauth_key: k).where(oauth_secret: s) }
    has_many :users

    validates :oauth_key, presence: true
    validates :oauth_secret, presence: true
  end
end
