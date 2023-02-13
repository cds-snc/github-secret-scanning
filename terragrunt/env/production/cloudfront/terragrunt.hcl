terraform {
  source = "../../../aws//cloudfront"
}

dependencies {
  paths = ["../hosted_zone", "../api"]
}

dependency "hosted_zone" {
  config_path = "../hosted_zone"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    hosted_zone_id = "1234567890"
  }
}

dependency "api" {
  config_path = "../api"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    api_function_name = "github-secret-scanning-api"
    api_function_url  = "https://api.github-secret-scanning.com"
  }
}

inputs = {
  api_function_name = dependency.api.outputs.function_name
  api_function_url  = dependency.api.outputs.function_url
  hosted_zone_id    = dependency.hosted_zone.outputs.hosted_zone_id
}  

include {
  path = find_in_parent_folders()
}
