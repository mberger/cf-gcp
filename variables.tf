variable "region" {
  default = "us-east1"
}

variable "region_zone" {
  default = "us-east1-b"
}

variable "org_id" {
  description = "325998602966"
}

variable "billing_account_id" {
  description = "01B494-EFBA64-4E3B48"
}

variable "credentials_file_path" {
  description = "Location of the credentials to use."
  default     = "~/.config/gcloud/michaelberger-terraform-admin.json"
}