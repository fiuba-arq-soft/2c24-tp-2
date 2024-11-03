# Generate a random string to avoid a container name collision
resource "random_string" "container_name" {
  length  = 25
  lower   = true
  upper   = false
  special = false
  numeric = false
}

# Create the GUIDs container
resource "azurerm_container_group" "tp2_container" {
  name                = random_string.container_name.result
  location            = azurerm_resource_group.tp2_resource_group.location
  resource_group_name = azurerm_resource_group.tp2_resource_group.name
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.tp2_sn_container.id]
  os_type             = "Linux"
  restart_policy      = "Always"

  container {
    name   = random_string.container_name.result
    image  = "arqsoft/guids:1.2.0"
    cpu    = 0.5
    memory = 0.5

    ports {
      port     = 8888
      protocol = "TCP"
    }
  }

  # Store the private IP
  provisioner "local-exec" {
    command = "sed -Ei.bak \"s/(remoteGuidsUri:)[^,]*,/\\1 'http:\\/\\/${azurerm_container_group.tp2_container.ip_address}:8888',/\" node/config.js"
  }
}
