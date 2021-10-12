terraform {
  required_version = ">=0.15.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.80.0"
    }
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "AzRG" {
  name     = "Devon-RG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "AzVN" {
  name                = "Devon-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.AzRG.location
  resource_group_name = azurerm_resource_group.AzRG.name
}

resource "azurerm_subnet" "AzSubnet" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.AzRG.name
  virtual_network_name = azurerm_virtual_network.AzRG.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_storage_account" "AzSA" {
  name                = "storageaccountname"
  resource_group_name = azurerm_resource_group.AzRG.name
  location                 = azurerm_resource_group.AzRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.AzSubnet.id]
  }

  tags = {
    environment = "Dev"
  }
}