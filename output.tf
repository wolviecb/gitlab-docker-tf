output "ip" {
  value = "${google_compute_instance.git.network_interface.0.access_config.0.nat_ip}"
}

output "hostname" {
  value = "${google_dns_record_set.git_dns.name}"
}
