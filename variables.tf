variable "azure_sid" {
}

variable "datadog_key" {
}

variable "region" {
  default = "eastus2"
}

variable "os_publisher" {
  default = "Canonical"
}

variable "os_offer" {
  default = "0001-com-ubuntu-server-jammy"
}

variable "os_sku" {
  default = "22_04-lts-gen2"
}

variable "os_version" {
  default = "latest"
}

variable "machine_sku" {
  default = "Standard_B1s"
}
