locals {
  GCP_WORKLOAD_IDENTITY_PROVIDER_NUM = google_iam_workload_identity_pool_provider.github.id
  GCP_WORKLOAD_IDENTITY_PROVIDER     = replace(google_iam_workload_identity_pool_provider.github.id, local.projects["prj_devops"].project_id, local.projects["prj_devops"].number)
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = local.projects["prj_devops"].project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "Github Pool"

  depends_on = [local.projects, google_project_iam_binding.binding]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = local.projects["prj_devops"].project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "Github provider"

  attribute_mapping = {
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "google.subject"       = "assertion.sub"
  }

  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.github, google_project_iam_binding.binding]
}

# Bind custom role for workload identity users
module "sa_wip_iam_binding_github" {
  for_each           = var.github_repos
  source             = "github.com/lab-gke-se/modules//iam/binding/service_account?ref=0.0.1"
  service_account_id = module.service_accounts[each.value].id
  role               = module.prj_roles["prj_devops/lab.prj.gke.wifUser"].id
  members = [
    each.key == "tenant_gke" ? "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/subject/repo:lab-gke-se/${each.key}:ref:refs/head/main" : "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/*"
    # principalSet://iam.googleapis.com/projects/52991355109/locations/global/workloadIdentityPools/github-pool/subject/repo:lab-gke-se/bootstrap:ref:refs/heads/main
  ]

  depends_on = [google_iam_workload_identity_pool_provider.github, google_project_iam_binding.binding]
}

