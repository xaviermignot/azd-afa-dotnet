param location string
param project string
param tags {
  *: string
}
param uniqueSuffix string

param storageAccountName string
param appInsightsInstrumentationKey string

resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'asp-${project}'
  location: location
  tags: tags

  kind: 'functionapp,linux'

  properties: {
    reserved: true
  }

  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource app 'Microsoft.Web/sites@2023-01-01' = {
  name: take('func-${project}-${uniqueSuffix}', 32)
  location: location
  tags: union(tags, {
      'azd-env-name': 'dev'
      'azd-service-name': 'afa'
    })

  kind: 'functionapp,linux'

  properties: {
    serverFarmId: plan.id
    reserved: true
    httpsOnly: true

    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: false
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
      ]
    }
  }
}
