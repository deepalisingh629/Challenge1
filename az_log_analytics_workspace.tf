// create log analytics workspace
resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = "${var.fn_name}-loganalytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

// create app insights
resource "azurerm_application_insights" "appi" {
  name                = var.appi_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.la_workspace.id
  application_type    = "web"
  disable_ip_masking = "false"
  sampling_percentage = "100"
  internet_ingestion_enabled = "true"
  internet_query_enabled =  true
  tags = var.tags
  depends_on = [
    azurerm_log_analytics_workspace.la_workspace
  ]
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurem_monitor_dianostic_setting" "appi_logs" {
  name = "${var.appi_name}-logs"
  target_resource_id = azurerm_application_insights.appi.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la_workspace.id

  enabled_log {
    category = "AuditEvent"

    retention_policy {
      enabled = false
    }
  }
  
  lifecycle {
    ignore_changes = [ tags, enabled_log ]
  }
}