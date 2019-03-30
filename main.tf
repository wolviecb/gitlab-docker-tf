provider "google" {
  project = "${var.project_name}"
  region  = "${var.region}"
  zone    = "${var.zone}"
  version = "~> 2.2"
}

provider "template" {
  version = "~> 1.0"
}

resource "google_compute_instance" "git" {
  name         = "${var.name}-${var.instance_name}"
  machine_type = "${var.instance_size}"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      type  = "pd-standard"
      size  = 10
    }
  }

  attached_disk {
    source      = "${google_compute_disk.git_data.self_link}"
    device_name = "${var.name}-${var.instance_name}"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  # metadata_startup_script = "${data.template_file.git_bootstrap.rendered}"

  metadata {
    user-data = "${data.template_file.user-data.rendered}"
  }
  tags = ["nginx", "ssh"]
}

resource "google_compute_disk" "git_data" {
  name = "${var.name}-${var.instance_name}-data"
  type = "pd-standard"
  size = "10"
}

data "template_file" "git_bootstrap" {
  template = "${file("${path.module}/starter.sh")}"

  vars {
    base_path         = "${var.base_path}"
    cert_path         = "${var.cert_path}"
    key_path          = "${var.key_path}"
    disk_name         = "${var.name}-${var.instance_name}"
    tls_name          = "${var.tls_bootstrap}"
    docker_network    = "${var.name}"
    nginx_container   = "${var.nginx_container}"
    gitlab_container  = "${var.gitlab_container}"
    runner0_container = "${var.runner0_container}"
    runner1_container = "${var.runner1_container}"
    runner2_container = "${var.runner2_container}"
  }
}

data "template_file" "user-data" {
  template = "${file("${path.module}/cloud-config")}"

  vars {
    base_path         = "${var.base_path}"
    cert_path         = "${var.cert_path}"
    key_path          = "${var.key_path}"
    disk_name         = "${var.name}-${var.instance_name}"
    tls_name          = "${var.tls_bootstrap}"
    docker_network    = "${var.name}"
    nginx_container   = "${var.nginx_container}"
    ngx_version       = "${var.ngx_version}"
    gitlab_container  = "${var.gitlab_container}"
    runner0_container = "${var.runner0_container}"
    runner1_container = "${var.runner1_container}"
    runner2_container = "${var.runner2_container}"
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

resource "google_dns_managed_zone" "dns_zone" {
  name        = "${var.name}"
  dns_name    = "${var.domain}."
  description = "Default DNS Zone"
}

resource "google_dns_record_set" "git_dns" {
  name = "git.${google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${google_dns_managed_zone.dns_zone.name}"

  rrdatas = ["${google_compute_instance.git.network_interface.0.access_config.0.nat_ip}"]
}

resource "google_dns_record_set" "root_dns" {
  name = "${google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${google_dns_managed_zone.dns_zone.name}"

  rrdatas = ["${google_compute_instance.git.network_interface.0.access_config.0.nat_ip}"]
}
