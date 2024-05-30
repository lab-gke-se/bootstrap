output "billing_account" {
  value = var.billing_account
}

output "location" {
  value = var.location
}

output "organization" {
  value = local.organization
}

output "folders" {
  value = local.folders
}

output "projects" {
  value = local.projects
}

output "service_accounts" {
  value = local.service_accounts
}

output "GCP_SERVICE_ACCOUNT" {
  value = local.service_accounts["sa_bootstrap"].email
}

output "GCP_STORAGE_BUCKET" {
  value = module.storage.name
}

output "GCP_WORKLOAD_IDENTITY_PROVIDER" {
  value = local.GCP_WORKLOAD_IDENTITY_PROVIDER
}

