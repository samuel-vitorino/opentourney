output "instance_name" {
  value = "${google_compute_instance.frontend-server.name}"
}

output "external_ip" {
  value = "${google_compute_instance.frontend-server.network_interface.0.access_config.0.nat_ip}"
}