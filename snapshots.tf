resource "yandex_compute_snapshot_schedule" "default" {
  name = "default"
  description    = "once a day for one week"
 
    schedule_policy {
    expression = "0 20 ? * *"
  }

  snapshot_count = 7

  retention_period = "168h"

  disk_ids = [
    "${yandex_compute_disk.nginx_a_boot_disk.id}",
    "${yandex_compute_disk.nginx_b_boot_disk.id}",
    "${yandex_compute_disk.bastion_ansible_boot_disk.id}",
    "${yandex_compute_disk.zabbix_boot_disk.id}",
    "${yandex_compute_disk.elastic_boot_disk.id}",
    "${yandex_compute_disk.kibana_boot_disk.id}",
  ]

  depends_on = [
     yandex_compute_instance.nginx_a,
     yandex_compute_instance.nginx_b,
     yandex_compute_instance.bastion_ansible,
     yandex_compute_instance.zabbix_vm,
     yandex_compute_instance.elastic_vm,
     yandex_compute_instance.kibana_vm
  ]

}