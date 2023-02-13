variable "github_token" {
  description = "The GitHub token used to retrieve the public key used to verify the alert signature."
  type        = string
  sensitive   = true
}
