// ---------------------------
targetScope = 'subscription'

// ---------------------------
param namespace string = 'bh'
param stage string = 'd'
param environment string = ''
param app string = ''
param location string = 'eastus2'

// db connection strings -----
param db_username string = ''
param db_hostname string = ''
@secure()
param db_password string = ''


// ---------------------------
var _label = replace('${namespace}-${stage}-${environment}-${location}-${app}','--','-')
var _tags = {}


// ============================================================================
// Create "core" resource group
resource rg_core 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg_${_label}-core'
  location: location
  tags: _tags
}

// Create keyvault ------------------------------------------------------------
module my_keyvault './keyvault.bicep' = {
  name: 'scraper_kv'
  scope: resourceGroup(rg_core.name)
  params: {
    namespace: namespace
    stage: stage
    environment: environment
    location: location
    app: app
  }
}

// // Set keyvault access policies -----------------------------------------------
// module rbac_kv_app_user './keyvault_access_policy.bicep' = {
//   name: 'kv_policy_app'
//   scope: resourceGroup(rg_core.name)
//   params: {
//     principalId: my_app.outputs.identity
//     vaultName: my_keyvault.outputs.name
//     mode: 'add'
//     secrets: ['get','list']
//   }
// }


// ============================================================================
// Create rg for function app -------------------------------------------------
resource rg_app 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg_${_label}-app'
  location: location
  tags: _tags
}

// Create function app --------------------------------------------------------
module my_app './app.bicep' = {
  name: 'scraper_app'
  scope: resourceGroup(rg_app.name)
  params: {
    keyVaultName: my_keyvault.outputs.name
    keyVaultId: my_keyvault.outputs.id
    namespace: namespace
    stage: stage
    environment: environment
    location: location
    name: 'scraper'
    db_hostname: db_hostname
    db_password: db_password
    db_username: db_username
  }
}

// ============================================================================
// Create the database resource group -----------------------------------------
resource rg_database 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg_${_label}-db'
  location: location
  tags: _tags
}

// Create the database --------------------------------------------------------
// module my_db './db_azsql_server.bicep' = {
//   name: 'scraper_db'
//   scope: resourceGroup(rg_database.name)
//   params: {
//     // namespace: namespace
//     // stage: stage
//     // environment: environment
//     location: location
//     serverName: 'scraperdb${uniqueString(rg_database.id)}'
//     databaseName: 'demo'
//     password: db_password
//     username: db_username
//   }
// }


