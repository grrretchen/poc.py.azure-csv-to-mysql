param location string
param serverName string
param databaseName string
param username string
@secure()
param password string = ''

// ============================================================================
// ----------------------------------------------------------------------------
resource server 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: username
    administratorLoginPassword: password
    version: '12.0'
  }
}

// ----------------------------------------------------------------------------
resource database 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: server
  name: databaseName
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
}

// ============================================================================
#disable-next-line outputs-should-not-contain-secrets
output connectionString string = 'Data Source=${server.properties.fullyQualifiedDomainName};Initial Catalog=${database.name};User ID=${username};Password=${password};'
