LtiBoxEngine::Engine.routes.draw do
  post "embed" => "lti#embed", as: :lti_embed
  match  "launch" => "lti#launch", as: :launch, via: [:get, :post]
  get "config(.xml)" => "lti#xml_config", as: :lti_xml_config
  get "health_check" => "lti#health_check"
  match "/" => "lti#launch", via: [:get, :post]
  match "/picker" => "lti#picker", via: [:get, :post]
  root "lti#launch"
  get "lti/index"
  get "test/backdoor"
end
