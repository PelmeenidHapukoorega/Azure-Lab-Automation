@description('Host name (address) of origin server')
param originHostName string

@description('name of the CDN profile')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('Name of CDN endpoint')
param endPointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('indicates whether CDN endpoint requires HTTPS connections.')
param httpsOnly bool

var originName = 'my-origin'

resource cdnProfile 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = {
  parent: cdnProfile
  name: endPointName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

@description('App service address')
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2024-02-01' = {
  parent: cdnProfile
  name: 'default-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

@description('Connecting endpoint to origin group')
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = {
  parent: originGroup
  name: 'app-service-origin'
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
  }
}

@description('Connects the endpoint to origin group')
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-02-01' = {
  parent: endpoint
  name: 'default-route'
  dependsOn: [
    origin
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: httpsOnly ? 'Enabled' : 'Disabled'
  }
}

@description('Host name of CDN endpoint.')
output endpointHostName string = endpoint.properties.hostName
