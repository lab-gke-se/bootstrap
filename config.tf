locals {
  # Local lookups for resources
  organization     = var.organization
  folders          = module.folders
  projects         = module.projects
  service_accounts = module.service_accounts
  org_roles        = module.org_roles
  prj_roles        = module.prj_roles

  regex_role = "(?P<project>.*)/(?P<id>.*)"

  # Substitutions for yaml files
  substitutions = {
    org_id      = local.organization.org_id
    domain      = local.organization.domain
    customer_id = local.organization.directory_customer_id
  }

  # Filenames for folder and project configuration files
  folder_filenames  = fileset("${path.module}/config/folders", "*.yaml")
  project_filenames = fileset("${path.module}/config/projects", "*.yaml")

  # Filenames for organization and project role configuration files
  org_role_filenames = fileset("${path.module}/config/roles/organization", "*.yaml")
  prj_role_filenames = fileset("${path.module}/config/roles/projects", "**/*.yaml")

  # Filenames for service account configuration files
  service_account_filenames = fileset("${path.module}/config/service_accounts", "*.yaml")

  # Organization configuration
  org_file = yamldecode(templatefile("${path.module}/config/organization.yaml", local.substitutions))

  # Folder configurations
  folder_files = {
    for filename in local.folder_filenames : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/folders/${filename}", local.substitutions))
  }
  # Project configurations
  project_files = {
    for filename in local.project_filenames : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/projects/${filename}", local.substitutions))
  }
  # Service Account configurations
  service_account_files = {
    for filename in local.service_account_filenames : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/service_accounts/${filename}", local.substitutions))
  }
  # Organization Role configurations
  org_role_files = {
    for filename in local.org_role_filenames : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/roles/organization/${filename}", local.substitutions))
  }
  # Project Role configurations
  prj_role_files = {
    for filename in local.prj_role_filenames : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/roles/projects/${filename}", local.substitutions))
  }

  # Organization IAM Policy 
  org_policy = {
    auditConfigs = try(local.org_file.iam_policy.auditConfigs, null)
    bindings = [
      for binding in try(local.org_file.iam_policy.bindings, []) : {
        role = (
          startswith(binding.role, "roles/") ? binding.role :
          startswith(binding.role, "organization/") ? module.org_roles[trimprefix(binding.role, "organization/")].id :
          null # Can't have project level roles for organizations
        )
        members = [
          for member in binding.members : (
            startswith(member, "serviceAccount:") ? try("serviceAccount:${module.service_accounts[trimprefix(member, "serviceAccount:")].email}", member) :
            member
          )
        ]
      }
    ]
  }

  # Folder IAM Policies 
  folder_policies = {
    for key, folder in local.folder_files : key => {
      bindings = [
        for binding in try(folder.iam_policy.bindings, []) : {
          role = (
            startswith(binding.role, "roles/") ? binding.role :
            startswith(binding.role, "organization/") ? local.org_roles[trimprefix(binding.role, "organization/")].id :
            null # Can't have project level roles for folders
          )
          members = [
            for member in binding.members : (
              startswith(member, "serviceAccount:") ? try("serviceAccount:${module.service_accounts[trimprefix(member, "serviceAccount:")].email}", member) :
              member
            )
          ]
        }
      ]
    } if try(folder.iam_policy, null) != null
  }

  # Project IAM Policies - can't use policy bindings on projects
  project_policies = {
    for key, project in local.project_files : key => {
      bindings = [
        for binding in try(project.iam_policy.bindings, []) : {
          role = binding.role
          #   startswith(binding.role, "roles/") ? binding.role :
          #   startswith(binding.role, "organization/") ? local.org_roles[trimprefix(binding.role, "organization/")].id :
          #   local.prj_roles[binding.role].id
          # )
          members = [
            for member in binding.members : (
              startswith(member, "serviceAccount:") ? try("serviceAccount:${module.service_accounts[trimprefix(member, "serviceAccount:")].email}", member) :
              member
            )
          ]
        }
      ]
    } if try(project.iam_policy, null) != null
  }
}
