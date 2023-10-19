terraform {
  source = "../../../aws//alert_compromise"
}

dependencies {
  paths = ["../api"]
}

dependency "api" {
  config_path = "../api"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    api_function_name = "github-secret-scanning-api"
  }
}

inputs = {
  api_function_name = dependency.api.outputs.function_name
}  

include {
  path = find_in_parent_folders()
}