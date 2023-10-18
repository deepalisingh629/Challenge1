# Create the web app For FE
resource "azurerm_linux_web_app" "webapp_fe" {
  name                  = "fitnessgeek"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.asp_fe.id
  https_only            = true
  tags = var.tags
  site_config { 
    minimum_tls_version = "1.2"
    always_on = true

    application_stack {
      node_version = "16-lts"
    }
  }
  
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
  }

  
  depends_on = [
    azurerm_service_plan.asp_fe,
    azurerm_application_insights.app_insights
  ]
}

// storage account for BE functionapp
resource "azurerm_storage_account" "fn-sa" {
  name                     = var.sa_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  public_network_access_enabled = false
  allow_nested_items_to_be_public = true
  shared_access_key_enabled = true
  infrastructure_encryption_enabled = true
  enable_https_traffic_only = true
  cross_tenant_replication_enabled = true
  tags = var.tags

  network_rules {
    default_action = "Deny"
    ip_rules = []
    virtual_network_subnet_ids = []
  }

  lifecycle {
    ignore_changes = [ tags,
    network_rules ]
  }
}

resource "azurerm_linux_function_app" "fnapp_be" {
  name                = var.fn_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.fn-sa.name
  storage_account_access_key = azurerm_storage_account.fn-sa.primary_access_key
  service_plan_id            = azurerm_service_plan.asp_be.id
  tags = var.tags
  

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
  }

  site_config {

  ip_restriction {
          virtual_network_subnet_id = azurerm_subnet.fe-subnet.id
          priority = 100
          name = "Frontend access only"
           }
  application_stack {
      python_version = 3.8
    }
  }

  identity {
  type = "SystemAssigned"
   }

 depends_on = [
   azurerm_storage_account.azurerm_storage_account.fn-sa,
   azazurerm_application_insights.app_insights
 ]
}

// vnet integration of BE functions
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_int_be" {
  app_service_id = azurerm_linux_function_app.fnapp_be.ids
  subnet_id      = azurerm_subnet.subnet02.id
  depends_on = [
    azurerm_linux_function_app.fnapp_be
  ]
}

// svnet integration of FE functions
resource "azurerm_app_service_virtual_network_swift_connection" "vnet-int_be" {
  app_service_id = azurerm_linux_web_app.webapp_fe.id
  subnet_id      = azurerm_subnet.subnet01.ids

  depends_on = [
    azurerm_linux_web_app.webapp_fe ]
}

