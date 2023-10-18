// Create App service plan for Frontend
resource "azurerm_service_plan" "asp_fe" {
  name                = var.asp_name_fe
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = var.kind
  sku_name            = var.sku_size
  tags = var.tags

  depends_on = [
    azurerm_subnet.fe-subnet
  ]

lifecycle {
  ignore_changes = [tags]
}
}


// Create App service plan for Backend
resource "azurerm_service_plan" "asp_be" {
  name                = var.asp_name_be
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = var.kind
  sku_name            = var.sku_size
  tags = var.tags

  depends_on = [
    azurerm_subnet.be-subnet
  ]

  lifecycle {
  ignore_changes = [tags]
}
}