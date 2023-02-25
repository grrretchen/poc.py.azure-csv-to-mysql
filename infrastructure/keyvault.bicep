targetScope = 'resourceGroup'

// PARENT --------------------
param namespace string
param stage string
param environment string
param location string = resourceGroup().location
param app string

// ---------------------------
param keyVaultName string = ''
param accessPolicies array = []


// The name must be a 1-127 character string, starting with a letter and containing only 0-9, a-z, A-Z, and -.
var _label = replace('${take(namespace,3)}-${take(stage,3)}-${app}','--','-')
var _name = take(keyVaultName != '' ? keyVaultName : '${_label}-${uniqueString(resourceGroup().id)}',24)

// ============================================================================
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {

  name: _name
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: accessPolicies
  }
}


// ============================================================================
output id string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output name string = _name
