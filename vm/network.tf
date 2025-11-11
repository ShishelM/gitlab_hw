resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#создаем NAT для выхода в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "my-gateway"
  shared_egress_gateway {}
}

#создаем сетевой маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "rt" {
  name       = "my-route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Определение Security Group
resource "yandex_vpc_security_group" "sg-web" {
  name       = "web-security-group"
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.network-1.id
  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "LAN-sg"
  network_id = yandex_vpc_network.network-1.id
  ingress {
    description    = "Allow 192.168.10.0/24"
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.10.0/24"]
    from_port      = 0
    to_port        = 65535
  }
    egress {
    description    = "Allow internet access via NAT"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

output "external_ip_address_gitlab" {
  value = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
}
output "internal_ip_address_gitlab" {
  value = yandex_compute_instance.gitlab.network_interface.0.ip_address
}
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}