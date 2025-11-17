variable "root_domain" {
  description = "Base Route53 hosted zone domain"
  type        = string
  default     = "tawanperry.top"
}

variable "app_subdomain" {
  description = "Subdomain for the app/site"
  type        = string
  default     = "site"
}
