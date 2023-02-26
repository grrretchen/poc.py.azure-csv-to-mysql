// ---------------------------
targetScope = 'resourceGroup'

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
param location string = resourceGroup().location   // actual azure cloud region
param label string = ''
param tags object = {}

param firstrun bool = false

// ---------------------------
param keyVaultName string = ''

//A vault's name must be between 3-24 alphanumeric characters. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens
var _label = replace('${take(namespace,3)}-${take(stage,3)}-${app}','-','')
var _name = take(keyVaultName != '' ? keyVaultName : 'kv-${_label}-${uniqueString(resourceGroup().id)}',24)


// ============================================================================
resource keyVaultNew 'Microsoft.KeyVault/vaults@2022-07-01' = if (firstrun) {
  name: _name
  location: location
  properties: {
    createMode: firstrun ? 'default' : 'recover'
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
  tags: tags
}

resource keyVaultExisting 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (!firstrun) {
  name: _name
}


// ============================================================================
output id string = firstrun ? keyVaultNew.id : keyVaultExisting.id
output url string = firstrun ? keyVaultNew.properties.vaultUri : keyVaultExisting.properties.vaultUri
output name string = _name

