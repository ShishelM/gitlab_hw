# считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}
data "yandex_compute_image" "gitlab_image" {
  family = "gitlab"
}
# Диски Gitlab
resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  # Зона должна совпадать с зоной инстанса!
  zone     = "ru-central1-a"
  size     = "20"
  image_id = data.yandex_compute_image.gitlab_image.image_id
}
resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  # Зона должна совпадать с зоной инстанса!
  zone     = "ru-central1-a"
  size     = "20"
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
}

# Виртуалка 1 (Gitlab)
resource "yandex_compute_instance" "gitlab" {
  name = "gitlab"
  hostname    = "gitlab"
  zone = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 8
    core_fraction = 20
  }

  scheduling_policy { preemptible = true }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.sg-web.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
}
# Виртуалка 2 (Ubuntu)
resource "yandex_compute_instance" "vm-1" {
  name = "vm-1"
  hostname    = "vm-1"
  zone = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy { preemptible = true }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.sg-web.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
}
