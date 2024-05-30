# Organization Policy 
# resource "google_organization_iam_policy" "policy" {
#   org_id      = local.organization.org_id
#   policy_data = jsonencode(local.org_policy)

#   depends_on = [local.projects]
# }

# Folder Policies
# resource "google_folder_iam_policy" "policy" {
#   for_each    = local.folder_policies
#   folder      = local.folders[each.key].name
#   policy_data = jsonencode(try(each.value, {}))

#   depends_on = [local.projects]
# }

# Project Bindings - projects iam at the binding level not the policy level 
resource "google_project_iam_binding" "binding" {
  for_each = { for binding in flatten([
    for key, policy in local.project_policies : [
      for binding in policy.bindings : {
        project = key
        role    = binding.role
        members = binding.members
      }
    ]
  ]) : "${binding.project}/${binding.role}" => binding }
  project = local.projects[each.value.project].project_id
  role = (
    startswith(each.value.role, "roles/") ? each.value.role :
    startswith(each.value.role, "organization/") ? local.org_roles[trimprefix(each.value.role, "organization/")].id :
    local.prj_roles[each.value.role].id
  )
  members = each.value.members

  depends_on = [local.projects, local.service_accounts, local.prj_roles, local.org_roles]
}
