output "rg_id" {
  value = "${module.resource_group.id}"
}

output "rg_location" {
  value = "${module.resource_group.location}"
}

output "vnetwork" {
  value      = "${module.vnets.name}"
  depends_on = ["${module.resource_group.name}"]
}

output "vsubnets" {
  value      = "${module.subnets.subnets}"
  depends_on = ["${module.vnets.name}"]
}

output "subnets ids" {
  sensitive = true
  value     = "${module.subnets.id}"
}

output "is frontend id" {
  sensitive = true
  value     = "${lookup(module.subnets.subnet_ids, "frontend")}"
}

output "vm count is " {
  value = "${module.vm_server.vm_count}"
}
