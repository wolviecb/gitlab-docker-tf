variable "instance_name" {
  description = "Name for the host instance"
  default     = "instance"
}

variable "instance_size" {
  description = "Size for the host instance"
  default     = "f1-micro"
}

variable "project_name" {
  description = "The GCE Project ID"
  default     = "the-project-id"
}

variable "name" {
  description = "Prefix name for resources"
  default     = "test"
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
  default     = "/something"
}

variable "cert_path" {
  description = "Path for self-signed certificate"
  default     = "/cert.pem"
}

variable "key_path" {
  description = "Path for self-signed key"
  default     = "/key.pem"
}

variable "nginx_container" {
  description = "Name for the nginx forwarder container"
  default     = "ngx"
}

variable "gitlab_container" {
  description = "Name for the gitlab container"
  default     = "gitlab"
}

variable "runner0_container" {
  description = "Name for the gitlab runner container"
  default     = "runner0"
}

variable "runner1_container" {
  description = "Name for the gitlab runner container"
  default     = "runner1"
}

variable "runner2_container" {
  description = "Name for the gitlab runner container"
  default     = "runner2"
}

variable "domain" {
  description = "DNS Domain name"
  default     = "test.com"
}

variable "ngx_version" {
  description = "Version for the ngx container"
  default     = "v1.0"
}
