module LtiBoxEngine
  BOX_CONFIG = YAML.load(File.read("#{Rails.root}/config/box.yml"))[Rails.env].symbolize_keys
end
