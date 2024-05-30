variable "domain" {
  description = "The domain"
  type        = string
}

variable "billing_account" {
  description = "The billing account"
  type        = string
}

variable "location" {
  description = "The location for resources"
  type        = string
}

variable "github_repos" {
  type = map(string)
}

variable "labels" {
  description = "Labels to apply to all foundation projects"
  type        = map(string)
  default     = {}
}
