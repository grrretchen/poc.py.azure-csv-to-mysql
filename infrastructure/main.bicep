/*
Order of creation:
- Core services
-- resource group
--- keyvault
- Function app
-- resource group
--- application insights
--- storage account
--- app service plan
--- function app
- database
- permission assignments
-- function app access to key vault
*/

// ---------------------------
targetScope = 'subscription'

// General tags ---------------------------------------------------------------
@description('Short form of the company ID or project ID')
param namespace string = 'demo'     // company ID
@description('Short form of the development stage, eg (d)ev, (t)est, (p)rod')
param stage string = 'd'            // (d)ev, (t)est, (p)roduction
@description('Short form of the deployment region, eg usea2 for eastus2')
param environment string = ''       // shortname for region
@description('Name of the service being provided, eg scraper')
param app string = ''               // application name
@description('Actual deployment location, eg eastus2')
param location string = 'eastus2'   // actual azure cloud region
param firstrun bool = false

// Database connection strings -----
param db_username string = ''
param db_hostname string = ''
@secure()
param db_password string = ''


// Create a re-usable name label
var _label = replace('${namespace}-${stage}-${!empty(environment) ? environment : location}-${app}','--','-')
var _shortLabel = replace('${take(namespace,3)}-${take(stage,3)}-${app}','-','')

var _tags = {
  namespace: namespace
  stage: stage
  environment: environment
  app: app
  label: _label
}

var _keyVaultName = take('kv-${_shortLabel}-${uniqueString(rg_core.id)}',24)

var _db_username = !empty(db_username) ? db_username : '${app}-admin'
var _db_password = !empty(db_password) ? db_password : 'my@${uniqueString(rg_database.id)}:p@55'
var _db_hostname = !empty(db_hostname) ? db_hostname : my_db.outputs.fqdn

// ============================================================================
// Create "core" resource group
resource rg_core 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${_label}-core'
  location: location
  tags: _tags
}

// Create keyvault ------------------------------------------------------------
module my_keyvault './keyvault.bicep' = {
  name: 'kv-${app}'
  scope: resourceGroup(rg_core.name)
  params: {
    keyVaultName: _keyVaultName
    namespace: namespace
    stage: stage
    environment: environment
    app: app
    label: _label
    location: location
    firstrun: firstrun
  }
}

// Set keyvault access policies -----------------------------------------------
module rbac_kv_app_user './keyvault_access_policy.bicep' = {
  name: 'kv-policy-app'
  scope: resourceGroup(rg_core.name)
  params: {
    principalId: my_app.outputs.identity
    vaultName: my_keyvault.outputs.name
    mode: 'add'
    secrets: ['get','list','delete']
  }
}


// ============================================================================
// Create rg for function app -------------------------------------------------
resource rg_app 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${_label}-app'
  location: location
  tags: _tags
}

// Create function app --------------------------------------------------------
module my_app './app.bicep' = {
  name: 'app-${app}'
  scope: resourceGroup(rg_app.name)
  params: {
    namespace: namespace
    stage: stage
    environment: environment
    app: app
    label: _label
    location: location
    keyVaultName: my_keyvault.outputs.name
    keyVaultId: my_keyvault.outputs.id
    keyVaultDatabaseKey: '${app}-database-credentials'
    db_hostname: _db_hostname
    db_password: _db_password
    db_username: _db_username
    tags: _tags
  }
}

// ============================================================================
// Create the database credentials --------------------------------------------
module kv_db_username './keyvault_secrets.bicep' = {
  scope: resourceGroup(rg_core.name)
  name: '${app}-db-username'
  params:{
    keyVault: my_keyvault.outputs.name
    secretName: 'db-username'
    value: _db_username
  }
}
module kv_db_password './keyvault_secrets.bicep' = {
  scope: resourceGroup(rg_core.name)
  name: '${app}-db-password'
  params:{
    keyVault: my_keyvault.outputs.name
    secretName: 'db-password'
    value: _db_password
  }
}
module kv_app_credentials './keyvault_secrets.bicep' = {
  scope: resourceGroup(rg_core.name)
  name: '${app}-db-credentials'
  params:{
    keyVault: my_keyvault.outputs.name
    secretName: '${app}-database-credentials'
    value: string({
      username: _db_username
      password: _db_password
      hostname: _db_hostname
    })
  }
}




// ============================================================================
// Create the database resource group -----------------------------------------
resource rg_database 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${_label}-db'
  location: location
  tags: _tags
}

// Create the database --------------------------------------------------------
module my_db './db_azsql_server.bicep' = {
  name: 'db-${app}'
  scope: resourceGroup(rg_database.name)
  params: {
    namespace: namespace
    stage: stage
    environment: environment
    app: app
    label: _label
    location: location
    // serverName: 'scraperdb${uniqueString(rg_database.id)}'
    databaseName: app
    username: _db_username
    password: _db_password
    tags: _tags
  }
}
    
    /*
*/
// ============================================================================
output keyVaultName string = my_keyvault.outputs.name
output keyVaultUrl string = my_keyvault.outputs.url

