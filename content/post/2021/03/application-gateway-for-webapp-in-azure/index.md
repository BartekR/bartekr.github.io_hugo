---
title: "Application Gateway for Web App in Azure" # Title of the blog post.
date: 2021-02-21 # Date of post creation.
draft: true # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
images:
  - src: "2021/02/21/application-gateway-for-webapp-in-azure/images/GitHubPages.png"
    alt: ""
    stretch: ""
tags: ['application gateway', 'web app', 'troubleshooting']
categories: ['azure']
---

I wanted to use an Application Gateway with the web applcation firewall to protect a Web App in Azure. When I first saw it, I was overwhelmed by the number of things I had to set up. Backend pools, listeners, rules, HTTP configurations, health probes... Click, click in Azure Portal, some guessing game, "pick from the backend" and voila - Application Gateway is ready.

And it does not work.

## First things first - how does it work

...content... jak jest zbudowany AG

## Scenariusz

1. Po co mi Application Gateway - Web Application Firewall
2. Utworzenie AG, WAF v1
3. Składowe (wykorzystać diagram na podstawie dokumentacji)
4. Plan - własna subdomena, przekierowanie na AG, utrzymywany adres subdomeny przy przekierowaniach
5. Dlaczego nie działa (pick header ...)
6. Jak zrobić, żeby działało (konfiguracja web app + własne domeny)
7. Problem - tylko HTTP, zamiast HTTPS
8. Certyfikat SSL od CA - jak zdobyć (przykład z zerossl.com - darmowy certyfikat na 90 dni)
9. Konfiguracja z SSL

```cmd
openssl pkcs12 -export -out webapp.bartekr.net.pfx -inkey private.key -in certificate.crt
```

Export password: bartekr12!

## Konfiguracja

Resource group: `webapp-rg`

- Public IP | `webapp-ip`
  - IP version: IPv4
  - SKU: basic
  - assignment: Dynamic
    - used for Application Gateway v1 - uses only dynamic IP
- Virtual Network | `webapp-vnet`
  - IP address space: 10.0.0.0/16 (65536 addresses)
  - subnets
    - `default` - 10.0.0.0/24
    - `ag-subnet` - 10.0.1.0/24
      - service endpoints
        - Microsoft.Web
      - subnet delegation: (none)
- Application Gateway | `webapp-ag`
  - tier: WAF
  - SKU Size: Medium
  - HTTP2: disabled
  - Web Application Firewall
    - status: enabled
    - mode: Detection
    - inspect request body: on
      - max request body size: 128 KB (default)
      - file upload limit: 100MB (default)
    - rule set: OWASP 3.0
    - advanced rule configuration: disabled
  - Backend pools
    - `backend-webapp`
      - backend targets:
        - type: App Services, target: bartekr.azurewebsites.net
  - HTTP Settings | `http-setting-override-domain-name-webapp.bartekr.net-custom-probe`
    - backend protocol: HTTPS
    - backend port: 443
    - backend authentication certificate: Use for App Service
    - cookie based affinity: disable
    - connection draining: disabled
    - request timeout (seconds): 20
    - override backend path: (empty)
    - override with new host name: yes
      - override with specific domain name: `webapp.bartekr.net`
    - use custom probe: yes | `probe-https-webapp.bartekr.net-probe-matching`
  - Frontend IP configurations
    - type: public
    - public IP address: `webapp-ip`
    - associated listeners: `listener-https`
  - Listeners
    - `https-listener`
      - protocol: HTTPS
      - port: 443
      - certificate: webapp.bartekr.net.pfx
      - associated rule: `rule-https`
      - listener type: basic
      error page url: no
  - Rules
    - `rule-https`
      - listener: `listener-https`
      - backend targets
        - target type: backend pool
        - backend target: `backend-webapp`
        http settings: `http-setting-override-domain-name-webapp.bartekr.net-custom-probe`
  - Health probes
    - `probe-https-webapp.bartekr.net-probe-matching`
      - protocol: HTTPS
      - host: `webapp.bartekr.net`
      - pick host name from backend HTTP settings: no
      - path: /
      - interval (seconds): 30
      - timeout (seconds): 30
      - unhealthy threshold: 3
      - use probe matching conditions: yes
        - HTTP response status code match: 200-399
        - HTTP response body match: (empty)
- Web App | `bartekr`
  - address: bartekr.azurewebsites.net
  - App Service Plan (S1) | `ASP-webapprg-9aaf`
    - pricing tier: Standard
    - instance size: Small
  - App Service authentication: Off
  - Custom domains
    - HTTPS only: on
    - bartekr.azurewebsites.net (default)
    - webapp.bartekr.net
      - SSL binding: SNI SSL
    - App Service domains: (none)
  - TLS/SSL settings
    - HTTPS only: on
    - minimum TLS version: 1.2
    - TLS/SSL Bindings
      - `webapp.bartekr.net`
        - certificate: `webapp.bartekr.net`
      - Private Key Certificates
        - `webapp.bartekr.net` (webapp.bartekr.net.pfx)
  - Networking
    - VNet integration: (none)
    - Access restrictions - bartekr.azurewebsites.net
      - rule: `allow-ag`
        - priority: 100
        - source: `webapp-vnet/ag-subnet`
        - action: Allow
        - HTTP headers: not configured
