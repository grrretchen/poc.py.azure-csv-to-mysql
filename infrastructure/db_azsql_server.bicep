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


param serverName string = ''
param databaseName string = ''
param username string = ''
@secure()
param password string = ''

// renaming -----
// var longName = '${label}-${uniqueString(resourceGroup().id)}'
var shortName = replace('${take(namespace,3)}-${take(stage,3)}-${app}','--','-')
var _serverName = !empty(serverName) ? serverName : take('sql-${label}-${uniqueString(resourceGroup().id)}',63)
var _databaseName = !empty(databaseName) ? databaseName : 'sqldb-${app}'

// ============================================================================
// ----------------------------------------------------------------------------
resource server 'Microsoft.Sql/servers@2022-05-01-preview' = {
  // servers -- global -- 1-63 -- Lowercase letters, numbers, and hyphens. -- Can't start or end with hyphen.
  name: _serverName
  location: location
  properties: {
    administratorLogin: username
    administratorLoginPassword: password
    version: '12.0'
  }
  tags: tags
}

// ----------------------------------------------------------------------------
resource database 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  // servers / databases -- server -- 1-128 -- Can't use: <>*%&:\/? or control characters -- Can't end with period or space.
  parent: server
  name: _databaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
   } 
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
    zoneRedundant: false
    readScale: 'Disabled'
  }
  tags: tags
}

// ============================================================================
#disable-next-line outputs-should-not-contain-secrets
output connectionString string = 'Data Source=${server.properties.fullyQualifiedDomainName};Initial Catalog=${database.name};User ID=${username};Password=${password};'
output fqdn string = server.properties.fullyQualifiedDomainName
