output "nginx-a_ip_adress" {
  value = yandex_compute_instance.nginx_a.network_interface[0].ip_address
}

output "nginx-b_ip_adress" {
  value = yandex_compute_instance.nginx_b.network_interface[0].ip_address
}

output "bastion-ansible_nat_ip_adress" {
  value = yandex_compute_instance.nginx_a.network_interface[0].nat_ip_address
}

output "alb_listener_external_ip_adress" {
  value = yandex_alb_load_balancer.alb_balancer.listener.0.endpoint.0.address.0.external_ipv4_address
}