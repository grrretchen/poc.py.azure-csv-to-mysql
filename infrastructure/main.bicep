// ---------------------------
targetScope = 'subscription'

// ---------------------------
param namespace string = 'bh'
param stage string = 'd'
param environment string = ''
// param name object
param location string = 'eastus2'

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
  }
}

// ============================================================================
resource rg_database 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg_${_label}-scraper-db'
  location: location
  tags: _tags
}
// ----------------------------------------------------------------------------

