$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lti_box_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lti_box_engine"
  s.version     = LtiBoxEngine::VERSION
  s.authors     = ["Brad Humphrey", "Eric Berry"]
  s.email       = ["brad@instructure.com", "ericb@instructure.com"]
  s.homepage    = "https://github.com/instructure/lti-box-engine"
  s.summary     = "Box.net LTI Application"
  s.description = "Box.net LTI Application as a mountable Rails engine"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.4"
  s.add_dependency "sass-rails", ">= 4.0.2"
  s.add_dependency "bootstrap-sass", "~> 3.1.0"
  s.add_dependency "ims-lti"
  s.add_dependency "ruby-box", "~> 1.14.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "poltergeist"
end
