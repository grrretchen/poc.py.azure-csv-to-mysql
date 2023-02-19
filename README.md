The following secrets must exist in GITHUB SECRETS:

`AZURE_DATABASE_CREDENTIALS` : A JSON string containing username, password, and hostname:
```json
{
    "username" : "adminuser",
    "password" : "supersecretpassword",
    "hostname" : "my-demo-sql-server.mysql.database.azure.com"
}
```

`AZURE_FUNCTIONAPP_PUBLISH_PROFILE` : An XML payload, exported from the Azure Function App UI.


### TODO:
- github bicep deployment script
- bicep keyvault creation
  - 
- bicep db creation
- bicep push db admin/pass/server to keyvault
- bicep pull db admin/pass/server to app config
  - https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli
  - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-resource#getsecret
