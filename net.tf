resource "yandex_vpc_network" "default" {
  name        = "project_vpc_network"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "subnet-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  }

resource "yandex_vpc_subnet" "subnet_b" {
  name           = "subnet-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  }

  resource "yandex_vpc_security_group" "sg_internal" {
  name        = "sg-internal"
  description = "SG internal vm to vm"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    from_port      = 0
    to_port        = 65535
  }

}

resource "yandex_vpc_security_group" "sg_nginx" {
  name        = "sg-nginx"
  description = "SG for nginx vms"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 80"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

}

resource "yandex_vpc_security_group" "sg_bastion_ansible" {
  name        = "sg-bastion-ansible"
  description = "SG for bastion-ansible"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 22"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  
}

resource "yandex_vpc_security_group" "sg_zabbix" {
  name        = "sg-zabbix"
  description = "SG for zabbix"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 8080"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  
}

resource "yandex_vpc_security_group" "sg_elastic_kibana" {
  name        = "sg-elastic-kibana"
  description = "SG for elastic-kibana"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 5601"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  
}