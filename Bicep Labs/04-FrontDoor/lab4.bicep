@description('Azure region for resource deployment')
param location string = 'westus3'

@description('Name of the app service app')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('Name of the app service plan SKU')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether CDN should be deployed')
param deployCdn bool = true

var appServicePlanName = 'toy-product-launch-plan'

module app 'lab4modules/app.bicep' = {
    name: 'toy-launch-app'
    params: {
        appServiceAppName: appServiceAppName
        appServicePlanName: appServicePlanName
        appServicePlanSkuName: appServicePlanSkuName
        location: location
    }
}

module cdn 'lab4modules/cdn.bicep' = if (deployCdn) {
    name: 'to-launch-cdn'
    params: {
        httpsOnly: true
        originHostName: app.outputs.appServiceAppHostName
    }
}


@description('Host name used to access website')
output WebSiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
