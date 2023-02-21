targetScope = 'resourceGroup'

// PARENT --------------------
param namespace string
param stage string
param environment string
param location string = resourceGroup().location

// ---------------------------
param keyVaultName string
param location string = resourceGroup().location
param tenantId string
param accessPolicies array = []


var _label = replace('${namespace}-${stage}-${environment}-${location}','--','-')
var _name = '${_label}-${name}-${uniqueString(resourceGroup().id)}'

// ============================================================================
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: accessPolicies
  }
}

output keyVaultResourceId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
