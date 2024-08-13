#Disks
resource "yandex_compute_image" "ubuntu-2204-lts" {
  source_family = "ubuntu-2204-lts"
}

resource "yandex_compute_image" "nat_instance_ubuntu" {
  source_family = "nat-instance-ubuntu-2204"
}

resource "yandex_compute_disk" "nginx_a_boot_disk" {
  
  name     = "nginx-a-boot-disk"
  zone     = "ru-central1-a"
  image_id = yandex_compute_image.ubuntu-2204-lts.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "nginx_b_boot_disk" {
  
  name     = "nginx-b-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-2204-lts.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "bastion_ansible_boot_disk" {
  
  name     = "bastion-ansible-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.nat_instance_ubuntu.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "zabbix_boot_disk" {
  
  name     = "zabbix-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-2204-lts.id
  type     = "network-hdd"
  size     = "10"

}

resource "yandex_compute_disk" "elastic_boot_disk" {
  
  name     = "elastic-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-2204-lts.id
  type     = "network-hdd"
  size     = "20"

}

resource "yandex_compute_disk" "kibana_boot_disk" {
  
  name     = "kibana-boot-disk"
  zone     = "ru-central1-b"
  image_id = yandex_compute_image.ubuntu-2204-lts.id
  type     = "network-hdd"
  size     = "10"

}

#Instances
resource "yandex_compute_instance" "nginx_a" {
  
  name                      = "nginx-a"
  hostname                  = "nginx-a"
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
    ip_address = "192.168.10.10"
    security_group_ids = [yandex_vpc_security_group.sg_internal.id]
  }

  metadata = {
    user-data = "${file("./nginx-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "nginx_b" {
  
  name                      = "nginx-b"
  hostname                  = "nginx-b"
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
    ip_address = "192.168.20.10"
    security_group_ids = [yandex_vpc_security_group.sg_internal.id]
  }

  metadata = {
    user-data = "${file("./nginx-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "bastion_ansible" {
  
  name                      = "bastion-ansible"
  hostname                  = "bastion-ansible"
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
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.30.10"
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
  hostname                  = "zabbix"
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
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.30.20"
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_zabbix.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./other-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "elastic_vm" {
  
  name                      = "elastic-vm"
  hostname                  = "elastic-vm"
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
    disk_id = yandex_compute_disk.elastic_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_b.id
    ip_address = "192.168.20.20"
    security_group_ids = [yandex_vpc_security_group.sg_internal.id]
  }

  metadata = {
    user-data = "${file("./other-config.yml")}"
    serial-port-enable=var.serial_console
  }

}

resource "yandex_compute_instance" "kibana_vm" {
  
  name                      = "kibana-vm"
  hostname                  = "kibana-vm"
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
    disk_id = yandex_compute_disk.kibana_boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.30.30"
    security_group_ids = [yandex_vpc_security_group.sg_internal.id,yandex_vpc_security_group.sg_kibana.id]
    nat            = true
  }

  metadata = {
    user-data = "${file("./other-config.yml")}"
    serial-port-enable=var.serial_console
  }

}