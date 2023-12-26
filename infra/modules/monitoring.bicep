param location string
param project string
param tags {
  *: string
}

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-${project}'
  location: location
  tags: tags

  properties: {
    features: {
      immediatePurgeDataOn30Days: true
    }
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${project}'
  location: location
  tags: tags
  kind: 'web'

  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

output lawName string = law.name
output appInsightsInstrumentationKey string = ai.properties.InstrumentationKey
