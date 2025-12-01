// UPDATED: Changed to West Europe for better quota availability
param location string = 'eastus'
param vmName string = 'minu-virtukas'
param adminUsername string = 'virtualhermit'

@secure()
param adminPassword string

// 1. Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: '${vmName}-ip'
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

// 2. NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'minu-virtukasNSG' 
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'allow-http'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
    ]
  }
}

// 3. VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.0.0/16' ] }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: { id: nsg.id }
        }
      }
    ]
  }
}

// 4. Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: { id: vnet.properties.subnets[0].id }
          publicIPAddress: { id: publicIp.id }
        }
      }
    ]
  }
}

// 5. Virtual Machine (UPDATED SKU to Standard_B2s)
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      // Changed to B-series. Much easier to get quota for!
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'StandardSSD_LRS' }
      }
    }
    networkProfile: {
      networkInterfaces: [ { id: nic.id } ]
    }
  }
}

// 6. Extension
resource nginxScript 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: vm
  name: 'customScript' 
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/MicrosoftDocs/mslearn-welcome-to-azure/master/configure-nginx.sh'
      ]
    }
    protectedSettings: {
      commandToExecute: './configure-nginx.sh && echo "<html><body><h1>MinuVirtukas Automated Lab</h1></body></html>" > /var/www/html/index.html'
    }
  }
}

output websiteUrl string = 'http://${publicIp.properties.ipAddress}'
