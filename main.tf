provider "azurerm" {
  features {}
  subscription_id = "c2bd123a-183f-43d5-bf41-c725494e595a"
  tenant_id       = "3180c264-31bc-4113-8f50-b7393a40457b"
  client_id       = "1a046c02-8c39-4f1d-b30b-93f41a9c6b15"
  client_secret   = "kUz8Q~qwom0J-MM5ZNqexXyUOguygMj5QELdhdl5"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  # Name is too short to be valid
  name                     = "ab"  # Must be between 3 and 24 characters
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "example-app-service-plan"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "example" {
  name                = "example-linux-function-app"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Use an invalid service plan ID format
  storage_account_name       = "storageaccount123"  # Valid name, but used with an invalid key
  storage_account_access_key = "short"  # Obviously invalid key (too short)
  service_plan_id            = "not-a-valid-service-plan-id"  # Invalid format

  site_config {}
}
