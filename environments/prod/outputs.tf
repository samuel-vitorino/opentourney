output "network" {
  value = "${module.vpc.network}"
}

output "subnet" {
  value = "${module.vpc.subnet}"
}

output "firewall_rule" {
  value = "${module.firewall.firewall_rule}"
}

output "instance_name" {
  value = "${module.frontend_server.instance_name}"
}

output "external_ip" {
  value = "${module.frontend_server.external_ip}"
}