#Create VPC
resource "yandex_vpc_network" "default" {
  name        = "project_vpc_network"
}

#Subnets
resource "yandex_vpc_subnet" "subnet_a" {
  name           = "subnet-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  route_table_id = yandex_vpc_route_table.private_nat.id
  }

resource "yandex_vpc_subnet" "subnet_b" {
  name           = "subnet-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  route_table_id = yandex_vpc_route_table.private_nat.id
  }

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  }

#Routing table
resource "yandex_vpc_route_table" "private_nat" {
  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion_ansible.network_interface.0.ip_address
  }
}

#Security groups
resource "yandex_vpc_security_group" "sg_internal" {
  name        = "sg-internal"
  description = "SG internal vm to vm"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "ANY"
    description    = "allow any connection from internal subnets"
	predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
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

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "yandex_vpc_security_group" "sg_zabbix" {
  name        = "sg-zabbix"
  description = "SG for zabbix"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 80"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 10051"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "yandex_vpc_security_group" "sg_kibana" {
  name        = "sg-kibana"
  description = "SG for kibana"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow tcp port 5601"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "yandex_vpc_security_group" "alb_balancer" {
  name       = "sg-alb-balancer"
  network_id = yandex_vpc_network.default.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Any protocol any port allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}