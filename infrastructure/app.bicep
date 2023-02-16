targetScope = 'resourceGroup'

// ---------------------------
param namespace string = 'bh'
param stage string = 'd'
param environment string = ''
param location string = 'eastus2'
param name string = 'app'

param storageAccountType string = 'Standard_LRS'

var _label = replace('${namespace}-${stage}-${environment}-${location}','--','-')
var _tags = {}
var _connectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
var functionAppName = '${_label}-${name}-${uniqueString(resourceGroup().id)}'
var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'
var appName = '${name}-${uniqueString(resourceGroup().id)}'

// ============================================================================
// ----------------------------------------------------------------------------
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi_${appName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// ----------------------------------------------------------------------------
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
location: location
  sku:{
    name: storageAccountType
  }
  kind:'Storage'
}

// ----------------------------------------------------------------------------
resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'asp_${appName}'
  location: location
  sku:{
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}


// ----------------------------------------------------------------------------  
resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: _connectionString
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: 'Python|3.9'
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
    httpsOnly: true
  }
}
