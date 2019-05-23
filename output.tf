output "ip" {
  value = google_compute_instance.git.network_interface[0].access_config[0].nat_ip
}

output "git" {
  value = google_dns_record_set.git_dns.name
}

output "short" {
  value = google_dns_record_set.short_dns.name
}

output "root" {
  value = google_dns_record_set.root_dns.name
}
