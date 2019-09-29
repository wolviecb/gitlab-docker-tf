terraform {
  required_version = ">= 0.12"
  required_providers {
    google = "~> 2.7"
  }
}

provider "google" {
  project = var.project_name
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "git" {
  name         = "${var.name}-${var.instance_name}"
  machine_type = var.instance_size

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      type  = "pd-standard"
      size  = var.boot_disk_size
    }
  }

  attached_disk {
    source      = google_compute_disk.git_data.self_link
    device_name = "${var.name}-${var.instance_name}"
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-config", {
      base_path         = var.base_path
      cert_path         = var.cert_path
      key_path          = var.key_path
      disk_name         = "${var.name}-${var.instance_name}"
      docker_network    = var.name
      tls_name          = var.tls_name
      nginx_container   = var.nginx_container
      ngx_version       = var.ngx_version
      short_version     = var.short_version
      gitlab_container  = var.gitlab_container
      runner0_container = var.runner0_container
      runner1_container = var.runner1_container
      runner2_container = var.runner2_container
    })
  }

  tags = ["nginx", "ssh"]

  labels = {
    system  = "git"
    version = var.tf_version
  }
}

resource "google_compute_disk" "git_data" {
  name = "${var.name}-${var.instance_name}-data"
  type = "pd-standard"
  size = "10"

  labels = {
    system  = "git"
    version = var.tf_version
  }
}

resource "google_compute_firewall" "forwarder_ingress" {
  name    = "${var.name}-${var.instance_name}-forwarder-ingress"
  network = "default"

  allow {
    protocol = "tcp"

    ports = [
      "80",
      "443",
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nginx"]
}

resource "google_compute_firewall" "ssh_ingress" {
  name    = "${var.name}-${var.instance_name}-ssh-ingress"
  network = "default"

  allow {
    protocol = "tcp"

    ports = [
      "22",
      "2222",
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
