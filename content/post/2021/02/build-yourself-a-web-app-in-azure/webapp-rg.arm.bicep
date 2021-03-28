resource webapp_ip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: 'webapp-ip'
  location: 'northeurope'
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      fqdn: '7e16c94e-d047-4d99-9354-b94df7eff72f.cloudapp.net'
      domainNameLabel: null
    }
    ipTags: []
  }
}

resource webapp_vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'webapp-vnet'
  location: 'northeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'ag-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: [
                '*'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource B644D3AE9783ECB8CFD2CD0ED94AB719D4CD79B6_webapp_rg_CentralUSwebspace 'Microsoft.Web/certificates@2018-11-01' = {
  name: 'B644D3AE9783ECB8CFD2CD0ED94AB719D4CD79B6-webapp-rg-CentralUSwebspace'
  location: 'Central US'
  properties: {
    hostNames: [
      'webapp.bartekr.net'
    ]
    password: null
  }
}

resource ASP_webapprg_9aaf 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: 'ASP-webapprg-9aaf'
  location: 'Central US'
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'app'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource webapp_vnet_ag_subnet 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${webapp_vnet.name}/ag-subnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Web'
        locations: [
          '*'
        ]
      }
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource webapp_vnet_default 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${webapp_vnet.name}/default'
  properties: {
    addressPrefix: '10.0.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource bartekr 'Microsoft.Web/sites@2018-11-01' = {
  name: 'bartekr'
  location: 'Central US'
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: 'bartekr.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: 'webapp.bartekr.net'
        sslState: 'SniEnabled'
        thumbprint: 'B644D3AE9783ECB8CFD2CD0ED94AB719D4CD79B6'
        hostType: 'Standard'
      }
      {
        name: 'bartekr.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: ASP_webapprg_9aaf.id
    reserved: false
    isXenon: false
    hyperV: false
    siteConfig: {}
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
  }
}

resource bartekr_8523f10ae69642c9b48acfad9c69edf5 'Microsoft.Web/sites/deployments@2018-11-01' = {
  name: '${bartekr.name}/8523f10ae69642c9b48acfad9c69edf5'
  location: 'Central US'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'VS Code'
    deployer: 'ZipDeploy'
    message: 'Created via a push deployment'
    start_time: '20.02.2021 08:40:00'
    end_time: '20.02.2021 08:40:05'
    active: true
  }
}

resource bartekr_bartekr_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  name: '${bartekr.name}/bartekr.azurewebsites.net'
  location: 'Central US'
  properties: {
    siteName: 'bartekr'
    hostNameType: 'Verified'
  }
}

resource bartekr_webapp_bartekr_net 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  name: '${bartekr.name}/webapp.bartekr.net'
  location: 'Central US'
  properties: {
    siteName: 'bartekr'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    thumbprint: 'B644D3AE9783ECB8CFD2CD0ED94AB719D4CD79B6'
  }
}

resource webapp_ag 'Microsoft.Network/applicationGateways@2020-05-01' = {
  name: 'webapp-ag'
  location: 'northeurope'
  properties: {
    sku: {
      name: 'WAF_Medium'
      tier: 'WAF'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'webapp-vnet', 'ag-subnet')
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'webapp.bartekr.net.pfx'
        properties: {}
      }
    ]
    authenticationCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: webapp_ip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend-webapp'
        properties: {
          backendAddresses: [
            {
              fqdn: 'bartekr.azurewebsites.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'http-setting-override-host-name-pick-from-backend-target-custom-probe'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: '${webapp_ag.id}/probes/probe-http-pick-hostname-from-backend-probe-matching'
          }
        }
      }
      {
        name: 'https-setting-override-pick-host-from-backend'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: '${webapp_ag.id}/probes/probe-https-pick-hostname-from-backend-probe-matching'
          }
        }
      }
      {
        name: 'http-setting-no-override'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: '${webapp_ag.id}/probes/probe-http-host-azurewebsites-probe-matching'
          }
        }
      }
      {
        name: 'http-setting-override-domain-name-webapp.bartekr.net-custom-probe'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          hostName: 'webapp.bartekr.net'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: '${webapp_ag.id}/probes/probe-http-webapp.bartekr.net-probe-matching'
          }
        }
      }
      {
        name: 'https-setting-override-omain-name-webapp.bartekr.net-custom-probe'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: 'webapp.bartekr.net'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: '${webapp_ag.id}/probes/probe-https-webapp.bartekr.net-probe-matching'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener-http'
        properties: {
          frontendIPConfiguration: {
            id: '${webapp_ag.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${webapp_ag.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-https'
        properties: {
          frontendIPConfiguration: {
            id: '${webapp_ag.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${webapp_ag.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${webapp_ag.id}/sslCertificates/webapp.bartekr.net.pfx'
          }
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'rule-http-no-override'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${webapp_ag.id}/httpListeners/listener-http'
          }
          backendAddressPool: {
            id: '${webapp_ag.id}/backendAddressPools/backend-webapp'
          }
          backendHttpSettings: {
            id: '${webapp_ag.id}/backendHttpSettingsCollection/http-setting-override-domain-name-webapp.bartekr.net-custom-probe'
          }
        }
      }
      {
        name: 'rule-https'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${webapp_ag.id}/httpListeners/listener-https'
          }
          backendAddressPool: {
            id: '${webapp_ag.id}/backendAddressPools/backend-webapp'
          }
          backendHttpSettings: {
            id: '${webapp_ag.id}/backendHttpSettingsCollection/https-setting-override-omain-name-webapp.bartekr.net-custom-probe'
          }
        }
      }
    ]
    probes: [
      {
        name: 'probe-http-pick-hostname-from-backend-probe-matching'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'probe-https-pick-hostname-from-backend-probe-matching'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'probe-http-host-azurewebsites-probe-matching'
        properties: {
          protocol: 'Http'
          host: 'bartekr.azurewebsites.net'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'probe-http-webapp.bartekr.net-probe-matching'
        properties: {
          protocol: 'Http'
          host: 'webapp.bartekr.net'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'probe-https-webapp.bartekr.net-probe-matching'
        properties: {
          protocol: 'Https'
          host: 'webapp.bartekr.net'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: false
  }
  dependsOn: [
    resourceId('Microsoft.Network/virtualNetworks/subnets', 'webapp-vnet', 'ag-subnet')
  ]
}

resource bartekr_web 'Microsoft.Web/sites/config@2018-11-01' = {
  name: '${bartekr.name}/web'
  location: 'Central US'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$bartekr'
    azureStorageAccounts: {}
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        vnetSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', 'webapp-vnet', 'ag-subnet')
        action: 'Allow'
        tag: 'Default'
        priority: 100
        name: 'allow-ag'
      }
      {
        ipAddress: 'Any'
        action: 'Deny'
        priority: 2147483647
        name: 'Deny all'
        description: 'Deny all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    reservedInstanceCount: 0
  }
  dependsOn: [
    resourceId('Microsoft.Network/virtualNetworks/subnets', 'webapp-vnet', 'ag-subnet')
  ]
}