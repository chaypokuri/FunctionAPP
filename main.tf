provider "azurerm" {
  features {}
subscription_id = "c2bd123a-183f-43d5-bf41-c725494e595a"
tenant_id = "3180c264-31bc-4113-8f50-b7393a40457b"
client_id = "1a046c02-8c39-4f1d-b30b-93f41a9c6b15"
client_secret = "kUz8Q~qwom0J-MM5ZNqexXyUOguygMj5QELdhdl5"

}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "linuxfunctionappsa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_function_app" "example" {
  name                = "example-linux-function-app"
  resource_group_name = "example-testrg"
  location            = "East-us"

  storage_account_name       = "teststorageaccount001"
  storage_account_access_key = "BjYCZEHX2OCqz/HWJdWp4rHfpLIAMJt0adLxzQnpItXCSyKwArG8iCgFfVNW/6pgabrtlniTcEaK+AStF5N8xQ=="
  service_plan_id            = "/subscriptions/c2bd123a-183f-43d5-bf41-c725494e595a/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-asp"
  virtual_network_subnet_id = "/subscriptions/c2bd123a-183f-43d5-bf41-c725494e595a/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-rg/subnets/test-subnet"
  site_config {}
}
