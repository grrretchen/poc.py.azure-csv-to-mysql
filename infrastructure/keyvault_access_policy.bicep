param vaultName string
param principalId string
param tenantId string = subscription().tenantId
param mode string = 'add'
param secrets array = []
param keys array = []
param certificates array = []

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${vaultName}/${mode}'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
        permissions: {
          secrets: secrets
          keys: keys
          certificates: certificates
        }
      }
    ]
  }
}
