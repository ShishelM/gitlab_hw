variable "cloud_id" {
  type    = string
  default = "b1gj3qbamvs4h8r8keio"
}
variable "folder_id" {
  type    = string
  default = "b1g9af9fe1gsnt7r0n36"
}
variable "flow" {
  type    = string
  default = "30-10"
}

# Параметры ВМ
variable "test" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
}

# Параметры сети
variable "network_name" {
  type    = string
  default = "my-network" 
   }

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24" 
  }
  
variable "zone" {
  type    = string
  default = "ru-central1-a" 
  }