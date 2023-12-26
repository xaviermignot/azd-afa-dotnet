param location string
param project string
param uniqueSuffix string
param tags {
  *: string
}

resource account 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: take(replace('st${project}${uniqueSuffix}', '-', ''), 24)
  location: location
  tags: tags

  sku: {
    name: 'Standard_LRS'
  }

  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }

  kind: 'StorageV2'
}

output accountName string = account.name
