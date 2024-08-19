resource "azurerm_resource_group" "rg" {
  name     = "tokyo-rg-2"
  location = "uksouth"

  tags = var.tags
}

resource "azurerm_data_factory" "df" {
  name                = "tokyo-df"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = "tokyostorageaccount179"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"

  tags = var.tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "dl2" {
  name               = "tokyo-dl2"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_databricks_workspace" "databricksw" {
  name                = "tokyo-databricks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"

  tags = var.tags
}

resource "azurerm_synapse_workspace" "sw" {
  name                                 = "tokyosynapse179"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.dl2.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = var.sql_administrator_login_password

  tags = var.tags
}
