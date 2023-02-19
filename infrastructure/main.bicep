// ---------------------------
targetScope = 'subscription'

// ---------------------------
param namespace string = 'bh'
param stage string = 'd'
param environment string = ''
// param name object
param location string = 'eastus2'

// db connection strings -----
param db_username string = ''
param db_hostname string = ''
@secure()
param db_password string = ''


// ---------------------------
var _label = replace('${namespace}-${stage}-${environment}-${location}','--','-')
var _tags = {}

// ============================================================================
resource rg_app 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg_${_label}-scraper-app'
  location: location
  tags: _tags
}

// ----------------------------------------------------------------------------
module app './app.bicep' = {
  name: 'scraper_app'
  scope: resourceGroup(rg_app.name)
  params: {
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
resource rg_database 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg_${_label}-scraper-db'
  location: location
  tags: _tags
}

// ----------------------------------------------------------------------------
module db './azsql_server.bicep' = {
  name: 'scraper_db'
  scope: resourceGroup(rg_database.name)
  params: {
    // namespace: namespace
    // stage: stage
    // environment: environment
    location: location
    serverName: 'scraperdb${uniqueString(rg_database.id)}'
    databaseName: 'demo'
    password: db_password
    username: db_username
  }
}

