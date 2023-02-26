targetScope = 'resourceGroup'

param keyVault string = ''
param secretName string = ''
param value string = ''


resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVault}/${secretName}'
  properties: {
    value: value
  }
}
