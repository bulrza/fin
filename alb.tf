resource "yandex_alb_target_group" "alb_target_group" {
  name      = "alb-target-group"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet_a.id}"
    ip_address   = "${yandex_compute_instance.nginx_a.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet_b.id}"
    ip_address   = "${yandex_compute_instance.nginx_b.network_interface.0.ip_address}"
  }
}


resource "yandex_alb_backend_group" "alb_backend_group" {
  name      = "alb-backend-group"
  http_backend {
    name = "nginx-http-backend"
    port = 80
    target_group_ids = ["${yandex_alb_target_group.alb_target_group.id}"]
        
    healthcheck {
      timeout = "10s"
      interval = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path  = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "http_router" {
  name      = "http-router"
}

resource "yandex_alb_virtual_host" "alb_virtual_host" {
  name                    = "alb-virtual-host"
  http_router_id          = yandex_alb_http_router.http_router.id
  route {
    name                  = "route-main"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.alb_backend_group.id
        timeout           = "5s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb_balancer" {
  name        = "alb-balancer"

  network_id  = yandex_vpc_network.default.id
  security_group_ids = [yandex_vpc_security_group.alb_balancer.id, yandex_vpc_security_group.sg_internal.id]
  
  allocation_policy {
      location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet_b.id 
    }
  }
  
  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.http_router.id
      }
    }
  }
  
}