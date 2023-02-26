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
param tags object = {}
param label string = ''


// var _label = replace('${namespace}-${stage}-${environment}-${app}','--','-')


param storageAccountType string = 'Standard_LRS'

// keyvault setup
param keyVaultName string = ''
param keyVaultId string = ''
param keyVaultDatabaseKey string = ''

// pre-defined names
param appInsightsName string = ''
param storageAccountName string = ''
param hostingPlanName string = ''
param functionAppName string = ''

// db connection strings -----
param db_username string = ''
param db_hostname string = ''
@secure()
param db_password string = ''

// renaming -----
// var longName = '${label}-${uniqueString(resourceGroup().id)}'
var shortName = replace('${take(namespace,3)}-${take(stage,3)}-${app}','--','-')
var _appInsightsName = !empty(appInsightsName) ? appInsightsName : 'appi-${label}'
var _functionAppName = !empty(functionAppName) ? functionAppName : take('func-${shortName}-${uniqueString(resourceGroup().id)}',60)
var _hostingPlanName = !empty(hostingPlanName) ? hostingPlanName : take('asp-${shortName}-${uniqueString(resourceGroup().id)}',40)
var _storageAccountName = !empty(storageAccountName) ? storageAccountName : take('st${replace(shortName,'-','')}${uniqueString(resourceGroup().id)}',24)

var _connectionString = 'DefaultEndpointsProtocol=https;AccountName=${_storageAccountName};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

// ============================================================================
// ----------------------------------------------------------------------------
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  // applicationInsights	-- scope: resource group -- 1-260 -- Can't use: %&\?/ or control characters -- Can't end with space or period.
  name: _appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
  tags: tags
}

// ----------------------------------------------------------------------------
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  // storageAccounts -- scope: global -- 3-24 -- Lowercase letters and numbers.
  name: _storageAccountName
  location: location
  sku:{
    name: storageAccountType
  }
  kind:'Storage'
  tags: tags
}

// ----------------------------------------------------------------------------
resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  // serverfarms -- resource group -- 1-40 -- Alphanumeric, hyphens and Unicode characters that can be mapped to Punycode
  name: _hostingPlanName
  location: location
  sku:{
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
  tags: tags
}


// ----------------------------------------------------------------------------  
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  // sites -- global --	2-60 -- Alphanumeric, hyphens and Unicode characters that can be mapped to Punycode -- Can't start or end with hyphen.
  name: _functionAppName
  location: location
  kind: 'functionapp,linux'
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
        {
          name: 'KEYVAULT_ID'
          value: keyVaultId
        }
        {
          name: 'KEYVAULT_NAME'
          value: keyVaultName
        }
        {
          name: 'KEYVAULT_KEY_DATABASE_CREDENTIALS'
          value: keyVaultDatabaseKey
        }
        {
          name: 'AZURE_DATABASE_CREDENTIALS'
          value: '{ "username" : "${db_username}", "password" : "${db_password}", "hostname": "${db_hostname}" }'
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
  tags: tags
}

// ============================================================================
output app object = functionApp
output identity string = functionApp.identity.principalId
