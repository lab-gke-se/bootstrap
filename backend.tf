terraform {
  backend "gcs" {
    bucket = "lab-gke-se-tf-state"
    prefix = "terraform/bootstrap"
  }
}

