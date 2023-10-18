data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.kv_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags = var.tags
  public_network_access_enabled = false
  network_acls {
    bypass = "AzureService"
    default_action = "Deny"
    ip_rules = []
    virtual_network_subnet_ids = []
  
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.obect_id
    key_permissions    = ["Get", "List", "Backup", "Create"]
    secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]
    storage_permissions = ["Get", "Backup", "Set"]
  }

  lifecycle {
    ignore_changes = [ network_acls,
    access_policy,
    tags,
    public_network_access_enabled ]
  }
}

resource "azurerm_private_endpoint" "example" {
  name                = "${var.kv_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.fe-subnet.id

  private_service_connection {
    name                           = "${var.kv_name}-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names = ["Vault"]
    is_manual_connection           = false
  }

  depends_on = [ azurerm_key_vault.kv ]
  tags = var.tags
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_key_vault_access_policy" "kv_access_01" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_function_app.fnapp_be.id
  key_permissions    = ["Get", "List", "Backup", "Create"]
  secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "Backup", "Set"]

  depends_on = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_access_policy" "kv_access_02" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_function_app.webapp_fe.id
  key_permissions    = ["Get", "List", "Backup", "Create"]
  secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "Backup", "Set"]

  depends_on = [azurerm_key_vault.kv]
}
