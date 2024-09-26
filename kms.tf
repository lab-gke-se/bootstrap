module "kms_key_ring" {
  source = "github.com/lab-gke-se/modules//kms/key_ring?ref=0.0.1"

  name     = "${local.projects["prj_devops"].name}-key-ring"
  project  = local.projects["prj_devops"].project_id
  location = var.location

  depends_on = [local.projects]
}

module "kms_key" {
  source = "github.com/lab-gke-se/modules//kms/key?ref=0.0.1"

  name     = "${local.projects["prj_devops"].name}-key"
  project  = local.projects["prj_devops"].project_id
  key_ring = module.kms_key_ring.id
  services = [
    "storage.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com"
  ]

  depends_on = [local.projects]
}

module "hpc_1_kms_key_ring" {
  source = "github.com/lab-gke-se/modules//kms/key_ring?ref=0.0.1"

  name     = "hpc-1"
  project  = local.projects["prj_devops"].project_id
  location = var.location

  depends_on = [local.projects]
}

module "hpc_1_kms_key" {
  source = "github.com/lab-gke-se/modules//kms/key?ref=0.0.1"

  name     = "hpc-1"
  project  = local.projects["prj_devops"].project_id
  key_ring = module.hpc_1_kms_key_ring.id
  services = [
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com"
  ]

  depends_on = [local.projects]
}

