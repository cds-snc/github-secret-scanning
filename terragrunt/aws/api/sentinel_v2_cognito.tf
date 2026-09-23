# The AWS half of the Sentinel forwarder's secretless path to the Logs Ingestion
# API (DCE/DCR), which replaces the retiring Data Collector API. Nothing is
# stored — the forwarder's IAM role is the only credential:
#
#   role -> cognito-identity:GetOpenIdTokenForDeveloperIdentity  (this pool)
#        -> that OIDC JWT as an Entra client assertion
#        -> token for the user-assigned managed identity
#           sentinel-forwarder-v2-aws-cognito (cds-snc/cds-azure-resources)
#        -> POST to the data collection endpoint
#
# The pool has to live in this account: identity pools carry no resource
# policy, so the one cds-aws-lz built in Log Archive cannot be called from here.
#
# This change adds only the pool. The forwarder switches to v2 in a follow-up,
# once the Azure identity has a federated credential for this pool — switching
# before that would fail every delivery.

locals {
  # Matches the pool in cds-aws-lz and the jamf forwarder.
  sentinel_forwarder_cognito_developer_provider_name = "azure-sentinel-access"
}

resource "aws_cognito_identity_pool" "sentinel_forwarder_v2" {
  identity_pool_name               = "sentinel-forwarder-v2-federation"
  allow_unauthenticated_identities = false
  developer_provider_name          = local.sentinel_forwarder_cognito_developer_provider_name

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
