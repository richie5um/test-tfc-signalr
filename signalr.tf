provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-signalr" {
  name     = "tf-signalr-richs"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_signalr_service" "sr-signalr" {
  name                = "sr-signalr-richs"
  resource_group_name = azurerm_resource_group.rg-signalr.name
  location            = azurerm_resource_group.rg-signalr.location

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  cors {
    allowed_origins = ["*"]
  }

  features {
    flag  = "ServiceMode"
    value = "Default"
  }
}

resource "azurerm_app_configuration" "ac-signalr" {
  name                = "ac-signalr-richs"
  resource_group_name = azurerm_resource_group.rg-signalr.name
  location            = azurerm_resource_group.rg-signalr.location
  sku                 = "standard"
}

resource "azurerm_key_vault" "kv-signalr" {
  name                = "kv-signalr-richs"
  location            = azurerm_resource_group.rg-signalr.location
  resource_group_name = azurerm_resource_group.rg-signalr.name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
    ]
  }
}

resource "azurerm_key_vault_secret" "kvs-signalr-connection" {
  name         = "AzureSignalRConnectionString"
  value        = azurerm_signalr_service.sr-signalr.primary_connection_string
  key_vault_id = azurerm_key_vault.kv-signalr.id
}

resource "null_resource" "script-signalr-setappconfig" {
  # triggers {
  #     trigger = "${uuid()}"
  # }

  # depends_on = ["azurerm_signalr_service.sr-signalr"]

  provisioner "local-exec" {
    command = "export AppConfigName='${azurerm_app_configuration.ac-signalr.name}' && export SignalrKvId='${azurerm_key_vault_secret.kvs-signalr-connection.id}' && ./appconfig.sh"
    # command = "export SignalrKvId=''export SignalRConnectionString='${azurerm_signalr_service.sr-signalr.primary_connection_string}' && ./appconfig.sh"
  }
}
