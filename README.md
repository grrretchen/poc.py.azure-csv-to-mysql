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
