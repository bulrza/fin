output "bastion-ansible_nat_ip_adress" {
  value = yandex_compute_instance.bastion_ansible.network_interface[0].nat_ip_address
}

output "bastion-ansible_ip_adress" {
  value = yandex_compute_instance.bastion_ansible.network_interface[0].ip_address
}

output "nginx-a_ip_adress" {
  value = yandex_compute_instance.nginx_a.network_interface[0].ip_address
}

output "nginx-a_fqdn" {
  value = yandex_compute_instance.nginx_a.fqdn
}

output "nginx-b_ip_adress" {
  value = yandex_compute_instance.nginx_b.network_interface[0].ip_address
}

output "nginx-b_fqdn" {
  value = yandex_compute_instance.nginx_b.fqdn
}

output "zabbix-vm_nat_ip_adress" {
  value = yandex_compute_instance.zabbix_vm.network_interface[0].nat_ip_address
}

output "zabbix-vm_ip_adress" {
  value = yandex_compute_instance.zabbix_vm.network_interface[0].ip_address
}

output "zabbix-vm_fqdn" {
  value = yandex_compute_instance.zabbix_vm.fqdn
}

output "elastic_vm_ip_adress" {
  value = yandex_compute_instance.elastic_vm.network_interface[0].ip_address
}

output "elastic_vm_fqdn" {
  value = yandex_compute_instance.elastic_vm.fqdn
}

output "kibana_vm_ip_adress" {
  value = yandex_compute_instance.kibana_vm.network_interface[0].ip_address
}

output "kibana_vm_fqdn" {
  value = yandex_compute_instance.kibana_vm.fqdn
}

output "kibana-vm_nat_ip_adress" {
  value = yandex_compute_instance.kibana_vm.network_interface[0].nat_ip_address
}

output "alb_listener_external_ip_adress" {
  value = yandex_alb_load_balancer.alb_balancer.listener.0.endpoint.0.address.0.external_ipv4_address
}