targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

var project = 'azd-afa-dotnet'
var uniqueSuffix = toLower(uniqueString(subscription().id, project, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${project}-${environmentName}'
  location: location
  tags: tags
}

module storage 'modules/storage.bicep' = {
  scope: rg
  name: '${deployment().name}-storage'
  params: {
    location: location
    project: project
    tags: union(tags, { module: 'storage.bicep' })
    uniqueSuffix: uniqueSuffix
  }
}

module monitoring 'modules/monitoring.bicep' = {
  scope: rg
  name: '${deployment().name}-monitoring'
  params: {
    location: location
    project: project
    tags: union(tags, { module: 'monitoring.bicep' })
  }
}

module functionApp 'modules/azureFunction.bicep' = {
  scope: rg
  name: '${deployment().name}-afa'
  params: {
    appInsightsInstrumentationKey: monitoring.outputs.appInsightsInstrumentationKey
    location: location
    project: project
    storageAccountName: storage.outputs.accountName
    tags: union(tags, { module: 'azureFunction.bicep' })
    uniqueSuffix: uniqueSuffix
  }
}
