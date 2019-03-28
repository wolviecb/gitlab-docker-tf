variable "instance_name" {
  description = "Name for the host instance"
  default     = ""
}

variable "instance_size" {
  description = "Size for the host instance"
  default     = ""
}

variable "project_name" {
  description = "The GCE Project ID"
  default     = ""
}

variable "name" {
  description = "Prefix name for resources"
  default     = ""
}

variable "region" {
  description = "Region to deploy resources"
  default     = "europe-north1"
}

variable "zone" {
  description = "Zone to deploy resources"
  default     = "europe-north1-a"
}

variable "base_path" {
  description = "Base path for attached disk"
  default     = ""
}

variable "cert_path" {
  description = "Path for self-signed certificate"
  default     = ""
}

variable "key_path" {
  description = "Path for self-signed key"
  default     = ""
}

variable "nginx_container" {
  description = "Name for the nginx forwarder container"
  default     = ""
}

variable "gitlab_container" {
  description = "Name for the gitlab container"
  default     = ""
}

variable "runner0_container" {
  description = "Name for the gitlab runner container"
  default     = ""
}

variable "runner1_container" {
  description = "Name for the gitlab runner container"
  default     = ""
}

variable "runner2_container" {
  description = "Name for the gitlab runner container"
  default     = ""
}

variable "domain" {
  description = "DNS Domain name"
  default     = ""
}

variable "tls_bootstrap" {
  description = "Hostname for tls self-signed certs"
  default     = ""
}
