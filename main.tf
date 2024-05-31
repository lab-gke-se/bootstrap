# The organization 
# module "organization" {
#   source = "github.com/lab-gke-se/modules//resources/organization"
#   domain = var.domain
# }

# Only supports folders under oganization to start with
module "folders" {
  for_each     = local.folder_files
  source       = "github.com/lab-gke-se/modules//resources/folder?ref=0.0.1"
  parent       = local.organization.name
  display_name = each.value.display_name
}

# This module intentionally doesn't support projects directly under the organization
module "projects" {
  for_each        = local.project_files
  source          = "github.com/lab-gke-se/modules//resources/project?ref=0.0.1"
  folder          = null # local.folders[each.value.parent].folder_id
  name            = each.value.display_name
  services        = try(each.value.services, [])
  labels          = try(each.value.labels, {})
  billing_account = try(each.value.billing_account, var.billing_account)
}

module "service_accounts" {
  for_each     = local.service_account_files
  source       = "github.com/lab-gke-se/modules//iam/service_account?ref=0.0.1"
  project      = local.projects[each.value.project].project_id
  name         = each.value.name
  display_name = try(each.value.display_name, null)
  description  = try(each.value.description, null)
}

module "org_roles" {
  for_each    = local.org_role_files
  source      = "github.com/lab-gke-se/modules//iam/role/organization?ref=0.0.1"
  org_id      = local.organization.org_id
  role_id     = each.value.name
  title       = each.value.title
  description = each.value.description
  permissions = each.value.includedPermissions
  stage       = each.value.stage
}

module "prj_roles" {
  for_each    = local.prj_role_files
  source      = "github.com/lab-gke-se/modules//iam/role/project?ref=0.0.1"
  project     = local.projects[regex(local.regex_role, each.key).project].project_id
  role_id     = each.value.name
  title       = each.value.title
  description = each.value.description
  permissions = each.value.includedPermissions
  stage       = each.value.stage
}
