@description('Azure region for resources')
param location string

@description('Name for app service app')
param appServiceAppName string

@description('Name of the app service plan')
param appServicePlanName string

@description('Name of the app service plan SKU')
param appServicePlanSkuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' ={
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsonly: true
  }
}

@description('Default host name of the app service app')
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
