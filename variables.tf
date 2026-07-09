variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "main_domain" {
  description = "The root domain name"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API Key"
}

variable "datadog_app_key" {
  description = "Datadog APP Key"
}

variable "datadog_api_url" {
  description = "Datadog API URL"
}
