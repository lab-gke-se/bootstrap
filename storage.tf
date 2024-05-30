module "storage" {
  source = "github.com/lab-gke-se/modules//storage/bucket"

  name                = "tf-state"
  project             = local.projects["prj_devops"].project_id
  location            = var.location
  kms_key_id          = module.kms_key.key_id
  data_classification = "foundation"

  depends_on = [local.projects, module.kms_key.encrypters, module.kms_key.decrypters]
}

