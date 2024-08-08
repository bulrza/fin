resource "yandex_compute_image" "ubuntu-1804-lts" {
  source_family = "ubuntu-1804-lts"
}

resource "yandex_compute_disk" "nginx_a_boot_disk" {
  
  name     = "nginx-a-boot-disk"
  zone     = "ru-central1-a"
  image_id = yandex_compute_image.ubuntu-1804-lts.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "nginx_b_boot_disk" {
  
  name     = "nginx-b-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-1804-lts.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "bastion_ansible_boot_disk" {
  
  name     = "bastion-ansible-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-1804-lts.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "zabbix_boot_disk" {
  
  name     = "zabbix-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-1804-lts.id
  type     = "network-hdd"
  size     = "30"

}

resource "yandex_compute_disk" "elastic_kibana_boot_disk" {
  
  name     = "elastic-kibana-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-1804-lts.id
  type     = "network-hdd"
  size     = "30"

}

resource "yandex_compute_instance" "nginx_a" {
  
  name                      = "nginx-a"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    memory = "2"
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    disk_id = yandex_compute_disk.nginx_a_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_a.id
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_nginx.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./nginx-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "nginx_b" {
  
  name                      = "nginx-b"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "2"
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    disk_id = yandex_compute_disk.nginx_b_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_b.id
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_nginx.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./nginx-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "bastion_ansible" {
  
  name                      = "bastion-ansible"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "2"
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion_ansible_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_b.id
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_bastion_ansible.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./bastion-ansible-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "zabbix_vm" {
  
  name                      = "zabbix"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "2"
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    disk_id = yandex_compute_disk.zabbix_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_b.id
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_zabbix.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./zabbix-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "elastic_kibana" {
  
  name                      = "elastic-kibana"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "2"
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    disk_id = yandex_compute_disk.elastic_kibana_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_b.id
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_elastic_kibana.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./elastic-kibana-config.yml")}"
    serial-port-enable=var.serial_console
  }

}